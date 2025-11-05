/// File
import * as base from './base';
import * as Model from './model';

/**
 * Delete file
 */
export const deleteFile = base.createJsonRequest<Model.DeleteFileRequest>((req) => ({
  url: `/file/${req.id}`,
  method: 'DELETE',
}))

/**
 * Get file
 */
export const getFile = base.createJsonRequest<Model.GetFileRequest, string>((req) => ({
  url: `/file/${req.id}`,
  method: 'GET',
}))

/**
 * Upload file
 */
export const uploadFile = base.createJsonRequest<Model.UploadFileRequest, string>((req) => {
  return {
    url: `/file/upload`,
    method: 'POST',
    data: req.toFormData(),
    onUploadProgress: req.onUploadProgress,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  };
})
