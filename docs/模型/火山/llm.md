# 火山多模态模型
go get -u github.com/volcengine/volcengine-go-sdk

##  doubao-seed-2-0-pro
旗舰级全能通用模型，面向 Agent 时代的复杂推理与长链路任务执行场景。强调多模态理解、长上下文推理、结构化生成与工具增强执行。复杂指令与多约束执行能力突出，可稳定应对多步复杂规划、复杂图文推理、视频内容理解与高难度分析等场景。

package main

import (
 "context"
 "fmt"
 "os"

 "github.com/samber/lo"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime/model/responses"
)

func main() {
 client := arkruntime.NewClientWithApiKey(
  //通过 os.Getenv 从环境变量中获取 ARK_API_KEY
  os.Getenv("ARK_API_KEY"),
  arkruntime.WithBaseUrl("<https://ark.cn-beijing.volces.com/api/v3>"),
 )
 // 创建一个上下文，通常用于传递请求的上下文信息，如超时、取消等
 ctx := context.Background()

 inputMessage := &responses.ItemInputMessage{
  Role: responses.MessageRole_user,
  Content: []*responses.ContentItem{
   {
    Union: &responses.ContentItem_Image{
     Image: &responses.ContentItemImage{
      Type:     responses.ContentItemType_input_image,
      ImageUrl: lo.ToPtr("https://ark-project.tos-cn-beijing.volces.com/doc_image/ark_demo_img_1.png"),
     },
    },
   },
   {
    Union: &responses.ContentItem_Text{
     Text: &responses.ContentItemText{
      Type: responses.ContentItemType_input_text,
      Text: "你看见了什么？",
     },
    },
   },
  },
 }

 resp, err := client.CreateResponses(ctx, &responses.ResponsesRequest{
  Model: "doubao-seed-2-0-pro-260215",
  Input: &responses.ResponsesInput{
   Union: &responses.ResponsesInput_ListValue{
    ListValue: &responses.InputItemList{ListValue: []*responses.InputItem{{
     Union: &responses.InputItem_InputMessage{
      InputMessage: inputMessage,
     },
    }}},
   },
  },
 })
 if err != nil {
  fmt.Printf("response error: %v\\n", err)
  return
 }
 fmt.Println(resp)
}

## Doubao-Seed-2.0-lite

面向高频企业场景兼顾性能与成本的均衡型模型，综合能力超越上一代Doubao-Seed-1.8。胜任非结构化信息处理、内容创作、搜索推荐、数据分析等生产型工作，支持长上下文、多源信息融合、多步指令执行与高保真结构化输出。在保障稳定效果的同时显著优化成本。
package main

import (
 "context"
 "fmt"
 "os"

 "github.com/samber/lo"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime/model/responses"
)

func main() {
 client := arkruntime.NewClientWithApiKey(
  //通过 os.Getenv 从环境变量中获取 ARK_API_KEY
  os.Getenv("ARK_API_KEY"),
  arkruntime.WithBaseUrl("<https://ark.cn-beijing.volces.com/api/v3>"),
 )
 // 创建一个上下文，通常用于传递请求的上下文信息，如超时、取消等
 ctx := context.Background()

 inputMessage := &responses.ItemInputMessage{
  Role: responses.MessageRole_user,
  Content: []*responses.ContentItem{
   {
    Union: &responses.ContentItem_Image{
     Image: &responses.ContentItemImage{
      Type:     responses.ContentItemType_input_image,
      ImageUrl: lo.ToPtr("https://ark-project.tos-cn-beijing.volces.com/doc_image/ark_demo_img_1.png"),
     },
    },
   },
   {
    Union: &responses.ContentItem_Text{
     Text: &responses.ContentItemText{
      Type: responses.ContentItemType_input_text,
      Text: "你看见了什么？",
     },
    },
   },
  },
 }

 resp, err := client.CreateResponses(ctx, &responses.ResponsesRequest{
  Model: "doubao-seed-2-0-lite-260215",
  Input: &responses.ResponsesInput{
   Union: &responses.ResponsesInput_ListValue{
    ListValue: &responses.InputItemList{ListValue: []*responses.InputItem{{
     Union: &responses.InputItem_InputMessage{
      InputMessage: inputMessage,
     },
    }}},
   },
  },
 })
 if err != nil {
  fmt.Printf("response error: %v\\n", err)
  return
 }
 fmt.Println(resp)
}

## Doubao-Seed-2.0-mini
面向低时延、高并发与成本敏感场景，强调快速响应与灵活推理部署。模型效果与Doubao-Seed-1.6相当。支持256k上下文、4档思考长度和多模态理解，适合成本和速度优先的轻量级任务。
package main

import (
 "context"
 "fmt"
 "os"

 "github.com/samber/lo"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime"
 "github.com/volcengine/volcengine-go-sdk/service/arkruntime/model/responses"
)

func main() {
 client := arkruntime.NewClientWithApiKey(
  //通过 os.Getenv 从环境变量中获取 ARK_API_KEY
  os.Getenv("ARK_API_KEY"),
  arkruntime.WithBaseUrl("<https://ark.cn-beijing.volces.com/api/v3>"),
 )
 // 创建一个上下文，通常用于传递请求的上下文信息，如超时、取消等
 ctx := context.Background()

 inputMessage := &responses.ItemInputMessage{
  Role: responses.MessageRole_user,
  Content: []*responses.ContentItem{
   {
    Union: &responses.ContentItem_Image{
     Image: &responses.ContentItemImage{
      Type:     responses.ContentItemType_input_image,
      ImageUrl: lo.ToPtr("https://ark-project.tos-cn-beijing.volces.com/doc_image/ark_demo_img_1.png"),
     },
    },
   },
   {
    Union: &responses.ContentItem_Text{
     Text: &responses.ContentItemText{
      Type: responses.ContentItemType_input_text,
      Text: "你看见了什么？",
     },
    },
   },
  },
 }

 resp, err := client.CreateResponses(ctx, &responses.ResponsesRequest{
  Model: "doubao-seed-2-0-mini-260215",
  Input: &responses.ResponsesInput{
   Union: &responses.ResponsesInput_ListValue{
    ListValue: &responses.InputItemList{ListValue: []*responses.InputItem{{
     Union: &responses.InputItem_InputMessage{
      InputMessage: inputMessage,
     },
    }}},
   },
  },
 })
 if err != nil {
  fmt.Printf("response error: %v\\n", err)
  return
 }
 fmt.Println(resp)
}
