import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction'
import { getToken, setToken } from './index'
import router from '@ohos.router';

//baseURL接口域名
const BASEURL: string = "https://iam.cn-southwest-2.myhuaweicloud.com/"
//登录页路由
const LOGINPAGEURL = 'pages/LoginPage'

//接口入参数据接口
export interface RequestParams {
  url: string
  method?: http.RequestMethod
  data?: Object
  headerContentType?: string
}


//接口请求返回数据类
export class ResponseResult {
  code: number //状态码
  message: string //处理信息
  data: Object | string //返回数据

  constructor(code?: number, message?: string, data?: Object | null | undefined) {
    this.code = code ?? 0
    this.message = message ?? ''
    this.data = data ?? ''
  }
}

/**
 *
 * @param params:接口请求参数（object类型）
 * {
 *  url :请求连接
 *  method ：请求方法
 *  data ：请求数据
 *  headerContentType ：请求头发送的数据格式
 * }
 * @returns Promise<ResponseResult>
 */


export function loginrequest(params: RequestParams): Promise<ResponseResult> {
  return new Promise(async (resolve: (res: ResponseResult) => void, reject: (res: ResponseResult | string | BusinessError | http.HttpResponse) => void) => {
    console.info(JSON.stringify(params.data));
    //请求头contentType
    let contentType: string = params.headerContentType || 'application/json' //默认提交数据类型为application/json
    //请求数据data
    let requestData: Object | undefined = params.data;

    let httpRequest = http.createHttp();
    httpRequest.request(BASEURL + params.url, {
      method: params.method, //默认get方法
      extraData: requestData,
      readTimeout: 30000,
      connectTimeout: 30000
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        console.info(JSON.stringify(data))
        //请求成功
        if (data.responseCode === 201) {
          //获取到token，并存在内部的preferences
          console.log(data.header["x-subject-token"]);
          setToken(data.header["x-subject-token"]);
          let response = new ResponseResult(201, '登录成功', data.header)
          console.info(`${JSON.stringify(response.data)}`)
          //状态码code=201表示请求成功,状态码可根据实际接口文档修改
          resolve(response);
          showToast(response.message)
        }
        //状态码code=401表示token失效,状态码可根据实际接口文档修改
        else if (data.responseCode === 401) { //跳转登录页
          let response = new ResponseResult(401, '登录失败', data.header)
          router.clear() //清空历史页面
          //跳转到登录页
          router.replaceUrl({
            url: LOGINPAGEURL
          })

          showToast(response.message)
          reject(data)
        }




      }
      //请求失败
      else {
        showToast(err.message)
        reject(err)
      }
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 当该请求使用完毕时，主动销毁该JavaScript Object。
      httpRequest.destroy();
    })
  })
}



//弹窗提示
export const showToast = (message?: string) => {
  promptAction.showToast({
    message: message || '请求出错',
    duration: 2000
  })
}

