import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False

# 生成示例数据
def generate_data():
    np.random.seed(42)
    n_samples = 1000
    
    # 类别1的数据（中心在(0,0)）
    X1 = np.random.randn(n_samples, 2) + np.array([0, 0])
    y1 = np.zeros(n_samples)
    
    # 类别2的数据（中心在(4,4)）
    X2 = np.random.randn(n_samples, 2) + np.array([4, 4])
    y2 = np.ones(n_samples)
    
    # 类别3的数据（中心在(4,0)）
    X3 = np.random.randn(n_samples, 2) + np.array([4, 0])
    y3 = 2 * np.ones(n_samples)
    
    X = np.vstack([X1, X2, X3])
    y = np.hstack([y1, y2, y3])
    
    return X, y

# 定义Softmax回归的决策函数
def softmax_predict(X, W, b):
    # 计算得分
    scores = X @ W.T + b
    # 应用softmax
    exp_scores = np.exp(scores - np.max(scores, axis=1, keepdims=True))
    probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
    return probs

# 生成网格点
def make_meshgrid(x, y, h=.02):
    x_min, x_max = x.min() - 1, x.max() + 1
    y_min, y_max = y.min() - 1, y.max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                         np.arange(y_min, y_max, h))
    return xx, yy

# 主函数
def main():
    # 生成数据
    X, y = generate_data()
    
    # 定义模型参数（这里使用一些预设的权重和偏置）
    W = np.array([
        [-1, -1],  # 类别1的权重
        [1, 1],    # 类别2的权重
        [1, -1]    # 类别3的权重
    ])
    b = np.array([0, -4, -4])  # 偏置
    
    # 创建图形
    plt.figure(figsize=(12, 8))
    
    # 绘制决策边界
    xx, yy = make_meshgrid(X[:, 0], X[:, 1])
    Z = softmax_predict(np.c_[xx.ravel(), yy.ravel()], W, b)
    Z = Z.argmax(axis=1)
    Z = Z.reshape(xx.shape)
    
    # 绘制决策区域
    plt.contourf(xx, yy, Z, alpha=0.4, cmap=ListedColormap(['#FF9999', '#66B2FF', '#99FF99']))
    
    # 绘制数据点
    scatter = plt.scatter(X[:, 0], X[:, 1], c=y, cmap=ListedColormap(['#FF0000', '#0000FF', '#00FF00']),
                         alpha=0.8, edgecolors='k')
    
    # 绘制决策边界
    plt.contour(xx, yy, Z, colors='k', linewidths=0.5)
    
    # 添加图例和标签
    plt.legend(handles=scatter.legend_elements()[0], 
              labels=['类别 1', '类别 2', '类别 3'],
              loc='upper right')
    plt.xlabel('特征 1')
    plt.ylabel('特征 2')
    plt.title('Softmax 回归的几何意义\n（决策边界和分类区域）')
    
    # 添加说明文字
    plt.text(-2, -2, '决策边界将空间分成三个区域\n每个区域对应一个类别\n区域边界是线性超平面',
             bbox=dict(facecolor='white', alpha=0.8))
    
    # 保存图片
    plt.savefig('static/images/softmax_geometry.png', dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
    main() 