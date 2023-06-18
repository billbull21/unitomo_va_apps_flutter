import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ogsalesapps/utils/custom_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../helpers/goes_date_helper.dart';
import '../../../utils/certificate.dart';
import '../../../utils/strings.dart';
import '/models/user_model.dart';

class ApiProvider {

  late Dio _dio;

  static final ApiProvider _apiProvider = ApiProvider._internal();

  factory ApiProvider(
      {String baseUrl = BASE_URL_API, Map<String, dynamic>? headers}) {
    _apiProvider._dio = Dio();
    _apiProvider._dio.interceptors.clear();
    _apiProvider._dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      // set baseUrl
      options.baseUrl = baseUrl;

      options.connectTimeout = const Duration(seconds: 30); //30s
      options.receiveTimeout = const Duration(seconds: 30); //30s

      String? token;
      // intialize token
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        token = box.get(selectedApiKeyPref) ?? box.get(apiKeyPref);
      }
      if (token != null) {
        options.headers['UserToken'] = token;
      }

      // add header
      if (headers != null) options.headers.addAll(headers);

      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      String id = "";
      String type = "";
      String model = "";
      String os = "";
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id ?? "";
        type = "Android";
        model = "${androidInfo.brand} - ${androidInfo.model}";
        os = "${androidInfo.version.release} - ${androidInfo.version.sdkInt}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? "";
        type = "iOS";
        model = "${iosInfo.model}";
        os = iosInfo.systemVersion ?? "";
      }
      Map<String, dynamic> dataDevice = {
        'device': {
          'id': id,
          'type': type, // android/ios
          'model': model, // xiaomi redmi / iPhone 11
          'os': os, // Lollipop 21 / 14
          'app_name': packageInfo.appName,
          'app_version': packageInfo.version,
          'build_number': packageInfo.buildNumber,
        },
      };

      if (options.data is Map) {
        options.data = Map<String, dynamic>.from(options.data);
        (options.data as Map<String, dynamic>).addAll(dataDevice);
      }

      options.headers.addAll({
        'User-Agent': dataDevice['device'],
      });

      return handler.next(options);
    }, onResponse: (Response resp, ResponseInterceptorHandler handler) {
      // print("RESP : $resp");
      return handler.next(resp);
    }, onError: (DioError error, ErrorInterceptorHandler handler) {
      // print("ERROR: $error");
      return handler.next(error);
    }));

    if (kDebugMode) {
      _apiProvider._dio.interceptors.add(LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        request: true,
        requestBody: true,
        // logPrint: (obj) => debugPrint(obj, wrapWidth: 90),f2345a3fb02a8ae0dc164e9bc974a9162044cca6
      ));
    }

    return _apiProvider;
  }

  ApiProvider._internal();

  Future doLogin(username, password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {
          'm_user_login': username,
          'm_user_password': password,
          'remember': true
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioError) {
        if (e.type == DioErrorType.response) {
          throw(e.response?.data);
        } else if (e.type == DioErrorType.other) {
          throw(e.message);
        } else if (e.type == DioErrorType.connectTimeout) {
          throw(e.message);
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<UserModel> fetchUserData() async {
    try {
      final response = await _dio.get("/getMe");
      return UserModel.fromJson(response.data['model']);
    } catch (e) {
      rethrow;
    }
  }

  Future updatePassword(data) async {
    try {
      final response = await _dio.post(
        "/Setup/User/_UpdatePassword",
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchPPn(companyId) async {
    try {
      final responseDate = await _dio.get("/SharedFunction/_GetDate");
      final date = DateFormat("yyyy-MM-dd").format(formatDateSystem(responseDate.data['model']));
      final response = await _dio.get("/SharedFunction/_GetPPNPercentage?tanggal=$date&companyID=$companyId");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchRecipientToken(String menu) async {
    try {
      final response = await _dio.get("/Other/Approval/_GetNextApproval?menuName=$menu");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchCustomerLocation({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/salesapps/maps/getMapEachMitraBySalesRegion",
        cancelToken: cancelToken
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchBusinessUnitForReport() async {
    try {
      final response = await _dio.get(
          "/Setup/BusinessUnit/_GetBUforReport?activeFlag=ACTIVE&pageSize=1000000");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDepoForReport(companyId) async {
    try {
      final response = await _dio.get(
          "/Setup/Depo/_GetDepoforReport?activeFlag=ACTIVE&pageSize=10000&companyID=$companyId");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListCustomer({
    CancelToken? cancelToken,
    required pageNumber,
    required periode,
    required employeeId,
    required filterMitra,
    required filterDivision,
    required sortType,
    required search,
  }) async {
    try {
      final response = await _dio.get("/salesapps/managmitra/get_mitra_list?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&periode=$periode&filterSortBy=$sortType&filter_mitra_achievement=$filterMitra&filter_division=$filterDivision&filterCust=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListSales({
    CancelToken? cancelToken,
    required pageNumber,
    required periode,
    required filterAchievement,
    required filterDivision,
    required sortType,
    required search,
  }) async {
    try {
      final response = await _dio.get("/salesapps/managesales/get_sales_list?pageSize=20&pageNumber=$pageNumber&periode=$periode&filterAchievement=$filterAchievement&sortType=$sortType&filterDivision=$filterDivision&sortType=DESC&search=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListSalesForNonSales({
    CancelToken? cancelToken,
    required pageNumber,
    String periode = '',
    String userSpvId = '',
    String sortType = 'DESC',
    required companyId,
    required depoId,
    required search,
  }) async {
    try {
      final response = await _dio.get("/salesapps/get_list_sales?pageSize=10&pageNumber=$pageNumber&m_company_id=$companyId&m_depo_id=$depoId&periode=$periode&search=$search&m_user_spv_id=$userSpvId&sortType=$sortType",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListSpvForNonSales({
    CancelToken? cancelToken,
    required pageNumber,
    String periode = '',
    required companyId,
    required depoId,
    required search,
  }) async {
    try {
      final response = await _dio.get("/salesapps/get_list_sales_spv?pageSize=10&pageNumber=$pageNumber&m_company_id=$companyId&m_depo_id=$depoId&search=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchCustomerById({
    CancelToken? cancelToken,
    required id,
  }) async {
    try {
      final response = await _dio.get("/Marketing/Customer/$id",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListProduct({
    required pageNumber,
    required depoId,
    required search,
    required divisionId,
    required itemType,
    required tSoHIsDisplay,
    required custId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/salesorder/get_item_list?pageSize=20&pageNumber=$pageNumber&m_division_id=$divisionId&m_item_type=$itemType&m_depo_id=$depoId&filterText=$search&t_so_h_isdisplay=$tSoHIsDisplay${tSoHIsDisplay ? '&m_cust_id=$custId' : ''}",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListDepoByCompanyId({CancelToken? cancelToken, required companyId, usingToken=false}) async {
    try {
      final response = await _dio.get("/Setup/Depo?pageSize=999&pageNumber=1&companyID=$companyId&usingtoken=$usingToken",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListDivision({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/Setup/Division?pageSize=100000&pageNumber=1",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListUserByEmployeeId({CancelToken? cancelToken, required employeeId}) async {
    try {
      final response = await _dio.get("/GetMe/getTokenByEmployeeId?employeeId=$employeeId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListDivisionAndroid({
    required companyId,
    required custId,
    required depoId,
    required userId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/Marketing/SalesOrder/GetSalesRegionForAndroid?CompanyId=$companyId&CustId=$custId&depoID=$depoId&userID=$userId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchBusinessUnitById(id) async {
    try {
      final response = await _dio.get("/Setup/businessunit/$id");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchSalesOrderById({id, CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/Marketing/SalesOrder/$id",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future saveTakeOrder(data) async {
    try {
      final response = await _dio.post("/Marketing/SalesOrder",
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future editTakeOrder(id, data) async {
    try {
      final response = await _dio.put("/Marketing/SalesOrder/$id",
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future sendApprovalTakeOrder(id, data) async {
    try {
      final response = await _dio.patch("/Marketing/SalesOrder/$id",
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future deleteTakeOrder(id) async {
    try {
      final response = await _dio.delete("/Marketing/SalesOrder/$id");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future saveGeoTag(id, data) async {
    try {
      final response = await _dio.patch("/Marketing/Customer/$id",
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future fetchListTakeOrder({
    CancelToken? cancelToken,
    required pageNumber,
    required status,
    required employeeId,
    required deliveryStatus,
    required periode,
    required divisionList,
    required filterCust,
    required search,
  }) async {
    try {
      final response = await _dio.get("/Marketing/SalesOrder/GetSalesOrderList?pageSize=20&pageNumber=$pageNumber&filterStatus=$status&filter_delivery_status=$deliveryStatus&periode=$periode&filter_division=$divisionList&employeeID=$employeeId&filterText=$search&filterCust=$filterCust",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailTakeOrder({
    CancelToken? cancelToken,
    required id,
  }) async {
    try {
      final response = await _dio.get("/Marketing/SalesOrder/GetSalesOrderDetail/$id",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchSalesAchievementInfo({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
  }) async {
    try {
      final response = await _dio.get("/salesapps/get_sales_achievmentinfo?pageSize=10&pageNumber=1&m_employee_id=$employeeId&periode=$periode",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchMitraStatistic({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
    required custId,
  }) async {
    try {
      final response = await _dio.get("/salesapps/managmitra/get_mitra_statistic?pageSize=10&pageNumber=1&m_cust_id=$custId&periode=$periode&m_emplyee_id=$employeeId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailCustomerTarget({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
    required custId,
    required divisionList,
    required filterDisplay,
  }) async {
    try {
      final response = await _dio.get("/salesapps/report/get_mitra_omset_vs_target?m_employee_id=$employeeId&m_cust_id=$custId&periode=$periode&filterDivision=$divisionList&filterDisplay=$filterDisplay",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailSalesmanTarget({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
    required divisionList,
    required filterDisplay,
  }) async {
    try {
      final response = await _dio.get("/salesapps/report/get_salesman_omset_vs_target?m_employee_id=$employeeId&periode=$periode&filterDivision=$divisionList&filterDisplay=$filterDisplay",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> fetchReportSalesmanTarget({
    CancelToken? cancelToken,
    required data,
    required Function(int progress, int total) onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post("/Marketing/SalesInvoice/_ReportSI_IOR",
        data: data,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> fetchReportSalesmanActivity({
    CancelToken? cancelToken,
    required data,
    required Function(int progress, int total) onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post("/Gps/_ReportSalesTrackingByBU",
        data: data,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListCollection({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
    required divisionList,
    required filterDisplay,
    required sortBy,
    required sortType,
    required search,
    required pageNumber,
  }) async {
    try {
      final response = await _dio.get("/salesapps/collection/getARList?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&periode=$periode&filterDivision=$divisionList&filterDisplay=$filterDisplay&sortBy=$sortBy&sortType=$sortType&filterText=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListTagihan({
    CancelToken? cancelToken,
    required employeeId,
    required periode,
    required divisionList,
    required custId,
    required filterDisplay,
    required sortBy,
    required sortType,
    required search,
    required pageNumber,
  }) async {
    try {
      final response = await _dio.get("/salesapps/collection/getARList?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&periode=$periode&filterDivision=$divisionList&filterDisplay=$filterDisplay&sortBy=$sortBy&sortType=$sortType&filterText=$search&m_cust_id=$custId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListReportStock({
    CancelToken? cancelToken,
    required itemType,
    required depoId,
    required sortBy,
    required sortType,
    required search,
    required pageNumber,
    required mDivisionId,
  }) async {
    try {
      final response = await _dio.get("/salesapps/inventory/get_stock_list_by_wh?pageSize=20&pageNumber=$pageNumber&m_depo_id=$depoId&m_item_type=$itemType&filterText=$search&sortBy=$sortBy&sortType=$sortType&m_division_id=$mDivisionId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListOutstandingProduct({
    CancelToken? cancelToken,
    required itemType,
    required employeeId,
    required depoId,
    required filterDisplay,
    required sortBy,
    required sortType,
    required divisionList,
    required search,
    required pageNumber,
    customerID
  }) async {
    try {
      String url = "/Stock/GetOutstandingProductList?pageSize=20&pageNumber=$pageNumber&m_division_id=$divisionList&m_item_type=$itemType&filter_display=$filterDisplay&depoID=$depoId&employeeID=$employeeId&filterText=$search&sortBy=$sortBy&sortType=$sortType";
      if (customerID != null) {
        url += "&customerID=$customerID";
      }
      final response = await _dio.get(url,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListOutstandingOrder({
    CancelToken? cancelToken,
    required employeeId,
    required depoId,
    required itemId,
    required filterDisplay,
    required sortBy,
    required sortType,
    required search,
    required pageNumber,
    customerID
  }) async {
    try {
      String url = "/Stock/GetOutstandingOrderList?pageSize=20&pageNumber=$pageNumber&filter_display=$filterDisplay&depoID=$depoId&employeeID=$employeeId&filterText=$search&sortBy=$sortBy&sortType=$sortType&itemId=$itemId";
      if (customerID != null) {
        url += "&customerID=$customerID";
      }
      final response = await _dio.get(url,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailSuratJalan({
    CancelToken? cancelToken,
    required arId,
  }) async {
    try {
      final response = await _dio.get("/Stock/GetSuratJalanDetail?id=$arId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailPaymentAR({
    CancelToken? cancelToken,
    required arId,
  }) async {
    try {
      final response = await _dio.get("/salesapps/collection/getDetailPaymentAR?t_ar_h_id=$arId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future insertSalesLocation({
    CancelToken? cancelToken,
    required data,
  }) async {
    try {
      final response = await _dio.post("/Gps/_SalesLocation",
        data: data,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future insertSalesCheckInOut({
    CancelToken? cancelToken,
    required data,
  }) async {
    try {
      final response = await _dio.post("/Gps/_SalesTracking",
        data: data,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future checkStatusSalesCheckInOut({
    CancelToken? cancelToken,
    required salesId,
  }) async {
    try {
      final response = await _dio.get("/Gps/_CheckSalesTracking?sales_id=$salesId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future checkTOP({
    required custGroupID ,
  }) async {
    try {
      final response = await _dio.get("/salesapps/check_TOP?custGroupID=$custGroupID");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchSummaryActivities({
    CancelToken? cancelToken,
    required periode,
  }) async {
    try {
      final response = await _dio.get("/salesapps/activity/getActivitiesSummary?periode=$periode",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailActivitiesCategory({
    CancelToken? cancelToken,
    required periode,
  }) async {
    try {
      final response = await _dio.get("/salesapps/activity/getActivitiesEachCategory?periode=$periode",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchDetailActivitiesMitra({
    CancelToken? cancelToken,
    required search,
    required pageNumber,
    required periode,
  }) async {
    try {
      final response = await _dio.get("/salesapps/activity/getActivitiesEachMitra?pageSize=20&pageNumber=$pageNumber&periode=$periode&filterText=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListRiwayatBayar({
    CancelToken? cancelToken,
    required search,
    required employeeId,
    required custId,
    required pageNumber,
    required startDate,
    required endDate,
  }) async {
    try {
      final response = await _dio.get("/salesapps/collection/getListRiwayatBayar?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&m_cust_id=$custId&startDate=$startDate&endDate=$endDate&filterText=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchTopSellingProduct({
    CancelToken? cancelToken,
    search,
    employeeId,
    companyId,
    depoId,
    custId,
    required pageNumber,
    required periode,
    required itemType,
    divisionList,
    required sortType,
  }) async {
    try {
      String query = "/Stock/GetTopSellingProductList?pageSize=20&pageNumber=$pageNumber&m_item_type=$itemType&periode=$periode&sortType=$sortType";
      if (divisionList != null) {
        query += "&m_division_id=$divisionList";
      }
      if (employeeId != null) {
        query += "&m_employee_id=$employeeId";
      }
      if (companyId != null) {
        query += "&m_company_id=$companyId";
      }
      if (depoId != null) {
        query += "&m_depo_id=$depoId";
      }
      if (custId != null) {
        query += "&m_cust_id=$custId";
      }
      if (search != null) {
        query += "&search=$search";
      }
      final response = await _dio.get(query,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchTopSellingProductDetail({
    CancelToken? cancelToken,
    required search,
    required itemId,
    required employeeId,
    required custId,
    required companyId,
    required depoId,
    required pageNumber,
    required periode,
    required sortBy,
    required sortType,
  }) async {
    try {
      final response = await _dio.get("/Stock/GetTopSellingProductDetailList?pageSize=20&pageNumber=$pageNumber&m_item_id=$itemId&m_employee_id=$employeeId&m_cust_id=$custId&m_company_id=$companyId&m_depo_id=$depoId&search=$search&periode=$periode&sortBy=$sortBy&sortType=$sortType",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchLiveActivities({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/salesapps/activity/getLiveActivities",
          cancelToken: cancelToken
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListSchedule({
    required pageNumber,
    required employeeId,
    required search,
    required type,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/schedule/getListSchedule?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&type=$type&filterText=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListScheduleDetail({
    required pageNumber,
    required employeeId,
    required search,
    required custId,
    required collectId,
    required periode,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/schedule/getListDetailSchedule?pageSize=20&pageNumber=$pageNumber&m_employee_id=$employeeId&m_cust_id=$custId&collect_id=$collectId&periode=$periode&filterText=$search",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchListCollectionRealizationDetail({
    required collectId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/marketing/collectiondetail?collectID=$collectId",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future saveCollectionRealization({
    required collectId,
    required data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put("/Marketing/collection/realization/$collectId",
        data: data,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchSummaryRevenue({
    required companyId,
    required depoId,
    required typeTrx,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/getSummaryRevenue?m_company_id=$companyId&m_depo_id=$depoId&typeTrx=$typeTrx",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchSummaryRevenueChart({
    required companyId,
    required depoId,
    required periode,
    required typeTrx,
    dataType = "BYTOKEN",
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/getSummaryRevenueChart?m_company_id=$companyId&m_depo_id=$depoId&periode=$periode&data_type=$dataType&typeTrx=$typeTrx",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchCustomerListNonSales({
    required pageNumber,
    required companyId,
    required depoId,
    required search,
    required sortType,
    required sortFields,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get("/salesapps/get_customer_list_nonsales?pageSize=10&pageNumber=$pageNumber&m_company_id=$companyId&m_depo_id=$depoId&search=$search&sortType=$sortType&sortFields=$sortFields",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchAllCommission({
    num? mEmployeeId,
    num? mUserId,
    required periode,
    CancelToken? cancelToken,
  }) async {
    try {
      String query = "/salesapps/getAllCommission?periode=$periode";
      if (mEmployeeId != null) {
        query += "&m_employee_id=$mEmployeeId";
      }
      if (mUserId != null) {
        query += "&m_user_id=$mUserId";
      }
      final response = await _dio.get(query,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchRevenueCommission({
    num? mEmployeeId,
    num? mUserId,
    required periode,
    CancelToken? cancelToken,
  }) async {
    try {
      String query = "/salesapps/getRevenueCommission?periode=$periode";
      if (mEmployeeId != null) {
        query += "&m_employee_id=$mEmployeeId";
      }
      if (mUserId != null) {
        query += "&m_user_id=$mUserId";
      }
      final response = await _dio.get(query,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchCollectionCommission({
    num? mEmployeeId,
    num? mUserId,
    required periode,
    CancelToken? cancelToken,
  }) async {
    try {
      String query = "/salesapps/getCollectionCommission?periode=$periode";
      if (mEmployeeId != null) {
        query += "&m_employee_id=$mEmployeeId";
      }
      if (mUserId != null) {
        query += "&m_user_id=$mUserId";
      }
      final response = await _dio.get(query,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

}
