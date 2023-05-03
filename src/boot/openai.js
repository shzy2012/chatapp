import { api } from "boot/axios";

/**
 * @description -封装OpenAI类型的接口方法
 */
export class OpenAIService {
  static post(data) {
    return api.post("/v1/chat/completions", data);
  }
}
