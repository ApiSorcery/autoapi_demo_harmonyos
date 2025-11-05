import { FormData } from '@ohos/axios';
import * as base from './base'

/**
 * Upload file
 */
export const uploadFile = base.createJsonRequest<FormData, string>((req) => ({
  url: `/file/upload`,
  method: 'POST',
  data: req,
  headers: {
    'Content-Type': 'multipart/form-data',
  }
}))