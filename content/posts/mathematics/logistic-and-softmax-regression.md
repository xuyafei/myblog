---
title: "Logistic 回归与 Softmax 回归：从原理到实现"
date: 2024-04-10
lastmod: 2024-04-10
draft: false
weight: 4
# 作者信息
author: "徐亚飞"
# 文章描述
description: "深入解析 Logistic 回归和 Softmax 回归的原理、数学推导、几何意义和代码实现，包括二分类和多分类问题的完整解决方案"
# 文章关键词
keywords: ["Logistic回归", "Softmax回归", "机器学习", "分类算法", "数学推导"]
# 文章分类和标签
tags: ["机器学习", "数学", "分类算法"]
categories: ["数学"]
# 文章设置
ShowToc: true
TocOpen: true
ShowReadingTime: true
ShowWordCount: true
ShowShareButtons: true
ShowBreadCrumbs: true
ShowCodeCopyButtons: true
---

## 一、什么是二分类问题？

二分类（Binary Classification）是机器学习中最基础的分类问题之一，目标是将样本分成两个类别，比如：
- 邮件是否为垃圾邮件（是/否）
- 用户是否会点击广告（会/不会）
- 图像里是否有人脸（有/没有）

形式上：给定输入特征 $x \in \mathbb{R}^n$，目标输出 $y \in \{0, 1\}$，我们想要学习一个函数 $f(x)$ 来预测 $y$。

## 二、Logistic 回归的核心思想

### 目标
输出一个概率值 $\hat{y} = P(y = 1 \mid x)$，落在 $[0, 1]$ 范围。

### 为什么不能直接用线性回归？
因为线性模型 $y = w^T x + b$ 的输出是 $(-\infty, +\infty)$，不适合做概率。

## 三、Sigmoid 函数登场！

Logistic 回归用 Sigmoid 函数把线性输出"压缩"到 $[0, 1]$ 范围，变成概率：

$$
\sigma(z) = \frac{1}{1 + e^{-z}} \quad \text{其中 } z = w^T x + b
$$

所以预测值为：

$$
\hat{y} = \sigma(w^T x + b) = \frac{1}{1 + e^{-(w^T x + b)}}
$$

这就是 Logistic 回归的模型！

## 四、损失函数：Log Loss（交叉熵）

### 为什么不用 MSE（均方误差）？
- 会导致梯度消失
- 不适合概率输出
- 不符合最大似然估计的优化目标

### Logistic 回归的损失函数：

$$
\mathcal{L}(\hat{y}, y) = -[y \log(\hat{y}) + (1 - y)\log(1 - \hat{y})]
$$

解释：
- 如果 $y = 1$，损失为 $-\log(\hat{y})$（越接近 1 越好）
- 如果 $y = 0$，损失为 $-\log(1 - \hat{y})$（越接近 0 越好）

### 总体损失函数（对所有样本取平均）：

$$
J(w, b) = \frac{1}{m} \sum_{i=1}^m -\left[y^{(i)} \log \hat{y}^{(i)} + (1 - y^{(i)}) \log (1 - \hat{y}^{(i)})\right]
$$

这是标准的二分类交叉熵损失函数（Binary Cross-Entropy）。

## 五、如何优化这个损失？

我们通常使用梯度下降法来最小化损失：

1. 初始化参数 $w, b$
2. 计算每个参数的梯度：
   $$
   \frac{\partial J}{\partial w_j} = \frac{1}{m} \sum_{i=1}^m ( \hat{y}^{(i)} - y^{(i)} ) x_j^{(i)}
   $$
   $$
   \frac{\partial J}{\partial b} = \frac{1}{m} \sum_{i=1}^m ( \hat{y}^{(i)} - y^{(i)} )
   $$
3. 更新参数：
   $$
   w := w - \alpha \frac{\partial J}{\partial w}, \quad b := b - \alpha \frac{\partial J}{\partial b}
   $$

这里的 $\alpha$ 是学习率。

## 六、Python 实现

```python
import numpy as np

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def compute_loss(y_hat, y):
    return -np.mean(y * np.log(y_hat + 1e-8) + (1 - y) * np.log(1 - y_hat + 1e-8))

def logistic_regression(X, y, lr=0.01, epochs=1000):
    m, n = X.shape
    w = np.zeros(n)
    b = 0

    for _ in range(epochs):
        z = np.dot(X, w) + b
        y_hat = sigmoid(z)
        
        dw = (1 / m) * np.dot(X.T, (y_hat - y))
        db = (1 / m) * np.sum(y_hat - y)

        w -= lr * dw
        b -= lr * db

    return w, b
```

## 七、Softmax 回归（多分类）

### 为什么需要 Softmax？

Logistic 回归只能处理两类。如果要处理 $K$ 类的分类问题（$y \in \{0,1,…,K-1\}$），我们需要使用 Softmax 函数来输出一个概率向量。

### 模型定义

设：
- 输入 $x \in \mathbb{R}^n$
- 权重矩阵 $W \in \mathbb{R}^{K \times n}$
- 偏置向量 $b \in \mathbb{R}^K$

计算每一类的打分（logits）：
$$
z = Wx + b \in \mathbb{R}^K
$$

经过 Softmax 得到概率：
$$
\hat{y}_i = \frac{e^{z_i}}{\sum_{j=1}^K e^{z_j}} \quad \text{for } i = 1, …, K
$$

### Python 实现

```python
import numpy as np

class SoftmaxRegression:
    def __init__(self, W, b):
        self.W = W  # 权重 shape: (K, n)
        self.b = b  # 偏置 shape: (K,)

    def softmax(self, z):
        exp_z = np.exp(z - np.max(z, axis=1, keepdims=True))  # 防止爆炸
        return exp_z / np.sum(exp_z, axis=1, keepdims=True)

    def predict_proba(self, X):
        z = X @ self.W.T + self.b  # shape: (m, K)
        return self.softmax(z)

    def predict(self, X):
        proba = self.predict_proba(X)
        return np.argmax(proba, axis=1)
```

## 八、几何解释

### Logistic 回归的几何意义

Logistic 回归的分类边界是 $w^T x + b = 0$，这是一个线性超平面：
- 在二维空间里，它是直线
- 三维里是平面
- 更高维是超平面

它将空间分成两部分：
- 一边是 $\hat{y} > 0.5$（预测为 1）
- 一边是 $\hat{y} < 0.5$（预测为 0）

### Softmax 回归的几何意义

Softmax 回归的边界是多个超平面，将空间划分为 $K$ 个区域，每个区域对应一个类别。

每一对类别之间的决策边界，是它们打分相等的地方：
$$
W_i^T x + b_i = W_j^T x + b_j
$$

这依然是线性超平面，因此 Softmax 回归是线性可分多分类器。

> 注：本文使用 KaTeX 渲染数学公式，确保最佳显示效果。 