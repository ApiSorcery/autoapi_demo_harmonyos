import type { AxiosRequestConfig } from '@ohos/axios'
import jsonRequest from '../../axios/clients/demo/json'

export const createJsonRequest = <TReq, TResp = any>(
  requestConfigCreator: (args: TReq) => AxiosRequestConfig,
) => {
  return (args: TReq) => <Promise<TResp>>jsonRequest(requestConfigCreator(args))
}

export const createNoParamsJsonRequest = <TResp = any>(
  requestConfigCreator: () => AxiosRequestConfig,
) => {
  return () => <Promise<TResp>>jsonRequest(requestConfigCreator())
}


