# DeepSeek大模型

## 列出模型

package main

import (
  "fmt"
  "net/http"
  "io/ioutil"
)

func main() {

  url := "<https://api.deepseek.com/models>"
  method := "GET"

  client := &http.Client {
  }
  req, err := http.NewRequest(method, url, nil)

  if err != nil {
    fmt.Println(err)
    return
  }
  req.Header.Add("Accept", "application/json")
  req.Header.Add("Authorization", "Bearer <TOKEN>")

  res, err := client.Do(req)
  if err != nil {
    fmt.Println(err)
    return
  }
  defer res.Body.Close()

  body, err := ioutil.ReadAll(res.Body)
  if err != nil {
    fmt.Println(err)
    return
  }
  fmt.Println(string(body))
}



## 首次调用 API
DeepSeek API 使用与 OpenAI 兼容的 API 格式，通过修改配置，您可以使用 OpenAI SDK 来访问 DeepSeek API，或使用与 OpenAI API 兼容的软件。

PARAM VALUE
base_url *        <https://api.deepseek.com>
api_key apply for an API key

* 出于与 OpenAI 兼容考虑，您也可以将 base_url 设置为 <https://api.deepseek.com/v1> 来使用，但注意，此处 v1 与模型版本无关。

* deepseek-chat 和 deepseek-reasoner 对应模型版本不变，为 DeepSeek-V3.2 (128K 上下文长度)，与 APP/WEB 版不同。deepseek-chat 对应 DeepSeek-V3.2 的非思考模式，deepseek-reasoner 对应 DeepSeek-V3.2 的思考模式。

调用对话 API
在创建 API key 之后，你可以使用以下样例脚本的来访问 DeepSeek API。样例为非流式输出，您可以将 stream 设置为 true 来使用流式输出。

curl
python
nodejs

### Please install OpenAI SDK first: `pip3 install openai`

import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get('DEEPSEEK_API_KEY'),
    base_url="<https://api.deepseek.com>")

response = client.chat.completions.create(
    model="deepseek-chat",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Hello"},
    ],
    stream=False
)

print(response.choices[0].message.content)


## 思考模式

DeepSeek 模型支持思考模式：在输出最终回答之前，模型会先输出一段思维链内容，以提升最终答案的准确性。您可以通过以下任意一种方式，开启思考模式：

设置 model 参数："model": "deepseek-reasoner"

设置 thinking 参数："thinking": {"type": "enabled"}

如果您使用的是 OpenAI SDK，在设置 thinking 参数时，需要将 thinking 参数传入 extra_body 中：

response = client.chat.completions.create(
  model="deepseek-chat",

# 

  extra_body={"thinking": {"type": "enabled"}}
)

API 参数
输入参数：

max_tokens：模型单次回答的最大长度（含思维链输出），默认为 32K，最大为 64K。
输出字段：

reasoning_content：思维链内容，与 content 同级，访问方法见样例代码。
content：最终回答内容。
tool_calls: 模型工具调用。
支持的功能：Json Output、Tool Calls、对话补全，对话前缀续写 (Beta)

不支持的功能：FIM 补全 (Beta)

不支持的参数：temperature、top_p、presence_penalty、frequency_penalty、logprobs、top_logprobs。请注意，为了兼容已有软件，设置 temperature、top_p、presence_penalty、frequency_penalty 参数不会报错，但也不会生效。设置 logprobs、top_logprobs 会报错。

多轮对话拼接
在每一轮对话过程中，模型会输出思维链内容（reasoning_content）和最终回答（content）。在下一轮对话中，之前轮输出的思维链内容不会被拼接到上下文中，如下图所示：

样例代码
下面的代码以 Python 语言为例，展示了如何访问思维链和最终回答，以及如何在多轮对话中进行上下文拼接。注意代码中在新一轮对话里，只传入了上一轮输出的 content，而忽略了 reasoning_content。

非流式
流式
from openai import OpenAI
client = OpenAI(api_key="<DeepSeek API Key>", base_url="<https://api.deepseek.com>")

# Turn 1

messages = [{"role": "user", "content": "9.11 and 9.8, which is greater?"}]
response = client.chat.completions.create(
    model="deepseek-reasoner",
    messages=messages,
    stream=True
)

reasoning_content = ""
content = ""

for chunk in response:
    if chunk.choices[0].delta.reasoning_content:
        reasoning_content += chunk.choices[0].delta.reasoning_content
    else:
        content += chunk.choices[0].delta.content

# Turn 2

messages.append({"role": "assistant", "content": content})
messages.append({'role': 'user', 'content': "How many Rs are there in the word 'strawberry'?"})
response = client.chat.completions.create(
    model="deepseek-reasoner",
    messages=messages,
    stream=True
)

# 
