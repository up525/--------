# 客户销售管理系统接口文档

## 基础信息

- **基础URL**: http://localhost:8080
- **请求方式**: 详见各接口定义
- **数据格式**: JSON
- **状态码**: 
  - `1`: 成功
  - `0`: 失败

## 通用响应格式

### 成功响应

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    // 具体数据
  }
}
```

### 失败响应

```json
{
  "code": 0,
  "message": "错误信息描述"
}
```

## 接口列表

### 1. 首页相关接口

#### 1.1 获取首页统计数据

- **URL**: `/dashboard`
- **方法**: `GET`
- **描述**: 获取首页的所有统计数据
- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "customerCount": {
      "value": 3250,
      "growthRate": 12.5
    },
    "monthlySales": {
      "value": 528000,
      "growthRate": 8.3
    },
    "orderCount": {
      "value": 186,
      "growthRate": 5.1
    },
    "newCustomerCount": {
      "value": 45,
      "growthRate": 15.2
    }
  }
}
```

#### 1.2 获取客户总数

- **URL**: `/customers/count`
- **方法**: `GET`
- **描述**: 获取系统中的客户总数及增长率
- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "value": 3250,
    "growthRate": 12.5
  }
}
```

#### 1.3 获取本月销售额

- **URL**: `/statistics/monthly-sales`
- **方法**: `GET`
- **描述**: 获取本月销售额及同比增长率
- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "value": 528000,
    "growthRate": 8.3
  }
}
```

#### 1.4 获取订单数量

- **URL**: `/orders/count`
- **方法**: `GET`
- **描述**: 获取订单总数及增长率
- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "value": 186,
    "growthRate": 5.1
  }
}
```

#### 1.5 获取新增客户数量

- **URL**: `/customers/new-count`
- **方法**: `GET`
- **描述**: 获取新增客户数量及增长率
- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "value": 45,
    "growthRate": 15.2
  }
}
```

### 2. 客户管理相关接口

#### 2.1 获取客户列表

- **URL**: `/customers/list`
- **方法**: `GET`
- **描述**: 获取客户列表，支持分页和搜索
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| page | Number | 是 | 当前页码 |
| pageSize | Number | 是 | 每页数量 |
| name | String | 否 | 客户名称（模糊搜索） |
| contact | String | 否 | 联系人（模糊搜索） |
| phone | String | 否 | 联系电话（模糊搜索） |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "total": 10,
    "list": [
      {
        "id": 1,
        "name": "阿里巴巴科技有限公司",
        "address": "杭州市余杭区文一西路969号",
        "industry": "互联网",
        "contact": "张三",
        "phone": "13800138000",
        "creatorId": 1,
        "creatorName": "管理员",
        "createdAt": "2023-01-15T08:30:00",
        "updatedAt": "2023-03-16T20:04:08"
      },
      // 更多客户数据...
    ],
    "pageNum": 1,
    "pageSize": 10,
    "size": 10,
    "pages": 1
  }
}
```

#### 2.2 根据ID获取客户详情

- **URL**: `/customers/{id}`
- **方法**: `GET`
- **描述**: 根据客户ID获取详细信息
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 客户ID |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "阿里巴巴科技有限公司",
    "address": "杭州市余杭区文一西路969号",
    "industry": "互联网",
    "contact": "张三",
    "phone": "13800138000",
    "creatorId": 1,
    "creatorName": "管理员",
    "createdAt": "2023-01-15T08:30:00",
    "updatedAt": "2023-03-16T20:04:08"
  }
}
```

#### 2.3 添加客户

- **URL**: `/customers`
- **方法**: `POST`
- **描述**: 添加新客户
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| name | String | 是 | 客户名称 |
| address | String | 是 | 地址 |
| industry | String | 是 | 行业 |
| contact | String | 是 | 联系人 |
| phone | String | 是 | 联系电话 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "添加成功",
  "data": {
    "id": 11,
    "name": "新增客户名称"
  }
}
```

#### 2.4 修改客户

- **URL**: `/customers`
- **方法**: `PUT`
- **描述**: 修改客户信息
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 客户ID |
| name | String | 否 | 客户名称 |
| address | String | 否 | 地址 |
| industry | String | 否 | 行业 |
| contact | String | 否 | 联系人 |
| phone | String | 否 | 联系电话 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "修改成功"
}
```

#### 2.5 删除客户

- **URL**: `/customers/{id}`
- **方法**: `DELETE`
- **描述**: A根据ID删除客户
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 客户ID |

- **响应示例**:

```json
{
  "code": 1,
  "message": "删除成功"
}
```

### 3. 开发计划管理相关接口

#### 3.1 获取开发计划列表

- **URL**: `/development/plans`
- **方法**: `GET`
- **描述**: 获取开发计划列表，支持分页和搜索
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| page | Number | 是 | 当前页码 |
| pageSize | Number | 是 | 每页数量 |
| title | String | 否 | 计划标题（模糊搜索） |
| status | Number | 否 | 计划状态 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "total": 5,
    "list": [
      {
        "id": 1,
        "title": "客户管理系统升级",
        "description": "升级客户管理系统，增加数据分析功能",
        "startTime": "2023-03-01T00:00:00",
        "endTime": "2023-06-30T00:00:00",
        "status": 1,
        "priority": 2,
        "creatorId": 1,
        "creatorName": "管理员",
        "createdAt": "2023-02-15T10:30:00",
        "updatedAt": "2023-03-15T15:20:00"
      },
      // 更多计划数据...
    ],
    "pageNum": 1,
    "pageSize": 10,
    "size": 5,
    "pages": 1
  }
}
```

#### 3.2 根据ID获取开发计划详情

- **URL**: `/development/plans/{id}`
- **方法**: `GET`
- **描述**: 根据计划ID获取详细信息
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 计划ID |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "id": 1,
    "title": "客户管理系统升级",
    "description": "升级客户管理系统，增加数据分析功能",
    "startTime": "2023-03-01T00:00:00",
    "endTime": "2023-06-30T00:00:00",
    "status": 1,
    "priority": 2,
    "creatorId": 1,
    "creatorName": "管理员",
    "createdAt": "2023-02-15T10:30:00",
    "updatedAt": "2023-03-15T15:20:00"
  }
}
```

#### 3.3 添加开发计划

- **URL**: `/development/plans`
- **方法**: `POST`
- **描述**: 添加新开发计划
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| title | String | 是 | 计划标题 |
| description | String | 是 | 计划描述 |
| startTime | String | 是 | 开始时间 |
| endTime | String | 是 | 结束时间 |
| status | Number | 是 | 状态(0:未开始,1:进行中,2:已完成) |
| priority | Number | 是 | 优先级(0:低,1:中,2:高) |

- **响应示例**:

```json
{
  "code": 1,
  "message": "添加成功",
  "data": {
    "id": 6,
    "title": "新增开发计划"
  }
}
```

#### 3.4 修改开发计划

- **URL**: `/development/plans`
- **方法**: `PUT`
- **描述**: 修改开发计划信息
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 计划ID |
| title | String | 否 | 计划标题 |
| description | String | 否 | 计划描述 |
| startTime | String | 否 | 开始时间 |
| endTime | String | 否 | 结束时间 |
| status | Number | 否 | 状态 |
| priority | Number | 否 | 优先级 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "修改成功"
}
```

#### 3.5 删除开发计划

- **URL**: `/development/plans/{id}`
- **方法**: `DELETE`
- **描述**: 根据ID删除开发计划
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| id | Number | 是 | 计划ID |

- **响应示例**:

```json
{
  "code": 1,
  "message": "删除成功"
}
```

### 4. 统计分析相关接口

#### 4.1 获取月度销售统计数据

- **URL**: `/statistics/monthly-sales`
- **方法**: `GET`
- **描述**: 获取月度销售统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| year | Number | 否 | 年份，默认当前年 |
| month | Number | 否 | 月份，不传则返回整年数据 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": [
    { "period": "一月", "amount": 120000 },
    { "period": "二月", "amount": 150000 },
    { "period": "三月", "amount": 180000 },
    // 更多月份数据...
  ]
}
```

#### 4.2 获取客户地区分布统计数据

- **URL**: `/statistics/customer-distribution`
- **方法**: `GET`
- **描述**: 获取客户地区分布统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| type | String | 否 | 统计类型，可选值：province/city，默认province |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": [
    { "name": "北京", "value": 150 },
    { "name": "上海", "value": 120 },
    { "name": "广东", "value": 180 },
    // 更多地区数据...
  ]
}
```

#### 4.3 获取产品销售占比统计数据

- **URL**: `/statistics/product-percentage`
- **方法**: `GET`
- **描述**: 获取产品销售占比统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| period | String | 否 | 统计周期，可选值：month/quarter/year，默认month |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": [
    { "name": "产品A", "value": 40 },
    { "name": "产品B", "value": 30 },
    { "name": "产品C", "value": 20 },
    { "name": "其他", "value": 10 }
  ]
}
```

#### 4.4 获取销售渠道分析统计数据

- **URL**: `/statistics/sales-channel`
- **方法**: `GET`
- **描述**: 获取销售渠道分析统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| period | String | 否 | 统计周期，可选值：month/quarter/year，默认month |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "channels": ["线下门店", "电商平台", "电话营销", "社交媒体", "合作伙伴"],
    "newCustomers": [20, 35, 15, 25, 10],
    "returningCustomers": [30, 40, 10, 15, 5]
  }
}
```

#### 4.5 获取销售人员业绩排名统计数据

- **URL**: `/statistics/salesperson-performance`
- **方法**: `GET`
- **描述**: 获取销售人员业绩排名统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| period | String | 否 | 统计周期，可选值：month/quarter/year，默认month |
| limit | Number | 否 | 返回记录数量，默认10条 |

- **响应示例**:

```json
{
  "code": 1,
  "message": "操作成功",
  "data": [
    { "name": "张三", "amount": 150000, "count": 25 },
    { "name": "李四", "amount": 120000, "count": 20 },
    { "name": "王五", "amount": 100000, "count": 18 },
    // 更多销售人员数据...
  ]
}
```

#### 4.6 生成统计数据

- **URL**: `/statistics/generate`
- **方法**: `POST`
- **描述**: 生成统计数据
- **请求参数**:

| 参数名 | 类型 | 必填 | 描述 |
|-------|------|-----|------|
| startDate | String | 是 | 开始日期 |
| endDate | String | 是 | 结束日期 |
| type | String | 是 | 统计类型，可选值：sales/customer/product |

- **响应示例**:

```json
{
  "code": 1,
  "message": "生成成功",
  "data": {
    "taskId": "TASK20230316001"
  }
}
```

## 附录

### 状态码说明

- `1`: 操作成功
- `0`: 操作失败

### 常见错误信息

- `参数错误`: 请求参数不符合要求
- `资源不存在`: 请求的资源不存在
- `权限不足`: 没有权限执行此操作
- `服务器错误`: 服务器内部错误 