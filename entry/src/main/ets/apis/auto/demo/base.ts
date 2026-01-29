import type { AxiosRequestConfig } from '@ohos/axios'
import type { BlobResp } from './model'
import jsonRequest from './httpClient/requests/json'
import blobRequest from './httpClient/requests/blob'

export const createJsonRequest = <TReq, TResp = any>(requestConfigCreator: (args: TReq) => AxiosRequestConfig) => {
  return (args: TReq) => <Promise<TResp>>jsonRequest(requestConfigCreator(args))
}

export const createNoParamsJsonRequest = <TResp = any>(requestConfigCreator: () => AxiosRequestConfig) => {
  return () => <Promise<TResp>>jsonRequest(requestConfigCreator())
}

export const createDownloadRequest = <TReq>(requestConfigCreator: (args: TReq) => AxiosRequestConfig) => {
  return (args: TReq) => blobRequest(requestConfigCreator(args)) as unknown as Promise<BlobResp>
}

export const createNoParamsDownloadRequest = (requestConfigCreator: () => AxiosRequestConfig) => {
  return () => blobRequest(requestConfigCreator()) as unknown as Promise<BlobResp>
}
