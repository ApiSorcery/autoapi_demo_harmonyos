import http from '@ohos.net.http';
import {ResultData, UserPageQueryDto, GetUserPagedResponse } from '../types/UserApiTypes';

/**
 * 用户分页查询接口
 * @param dto 查询参数
 * @param callback 回调函数，返回结果或 null
 */
export function fetchUserPage(dto: UserPageQueryDto, callback: (result: GetUserPagedResponse | null) => void) {
  let httpRequest = http.createHttp();
  httpRequest.request(
    "https://www.apisorcery.com/demo-api/user/paged",
    {
      method: http.RequestMethod.POST,
      header: { "Content-Type": "application/json" },
      extraData: JSON.stringify(dto)
    },
    (err, data) => {
      if (!err) {
        let resp: ResultData<GetUserPagedResponse>;
        if (typeof data.result === 'string') {
          try {
            resp = JSON.parse(data.result) as ResultData<GetUserPagedResponse>;
          } catch (e) {
            console.error('响应解析失败:', data.result);
            callback(null);
            httpRequest.destroy();
            return;
          }
        } else {
          resp = data.result as ResultData<GetUserPagedResponse>;
        }
        if (resp.status === 0 && resp.data) {
          callback(resp.data as GetUserPagedResponse);
        } else {
          callback(null);
        }
      } else {
        console.error("请求失败:", JSON.stringify(err));
        callback(null);
      }
      httpRequest.destroy();
    }
  );
}
