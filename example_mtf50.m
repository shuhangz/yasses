%% MTF50示例 - 使用yasses工具计算MTF50值
% 这个示例展示了如何使用yasses工具箱中的getMTF50函数来计算
% MTF为0.5时对应的空间频率，这是评估光学系统分辨率的重要指标

clear
close all
clc

%% STEP 1: 读取西门子星图像
star = imread('Star.tif');

if size(star, 3) == 3
    star = rgb2gray(star);
end

%% STEP 2: 设置放大倍率和像素尺寸
% 如果需要图像侧分辨率，设置magnification = 1
% 其他放大倍率下，将计算物体侧MTF
magnification = 1;  
pxsize = 6.5;         % 像素尺寸，单位微米

%% STEP 3: 运行yasses获取MTF曲线
% 获取yasses子函数的句柄
ya = yasses();
% 设置是否显示图形，1=显示，0=不显示
showplots = 1;
% 从西门子星图获取MTF曲线并显示结果
[lpmm, mtf] = ya.getMTFfromStar(star, magnification, pxsize, showplots);

%% STEP 4: 填充低频MTF数据并计算MTF50
% 使用高斯拟合填充低频MTF数据
mtf_filled = ya.extrapolateLowLPMM(lpmm, mtf, 'gaussian');

% 计算并显示MTF50值
fprintf('原始MTF数据:\n');
mtf50_raw = ya.getMTF50(lpmm, mtf);

fprintf('经过高斯填充后的MTF数据:\n');
mtf50_filled = ya.getMTF50(lpmm, mtf_filled);

%% STEP 5: 显示结果
if showplots
    figure;
    hold on;
    plot(lpmm, mtf, 'k-', 'LineWidth', 2, 'DisplayName', '原始MTF');
    plot(lpmm, mtf_filled, 'r--', 'LineWidth', 2, 'DisplayName', '高斯填充MTF');
    % 在MTF=0.5处画一条水平线
    yline(0.5, 'b-.', 'MTF50', 'LineWidth', 1.5);
    % 在MTF50位置画垂直线
    if ~isnan(mtf50_filled)
        xline(mtf50_filled, 'g-.', ['MTF50 = ', num2str(mtf50_filled, '%.2f'), ' lp/mm'], 'LineWidth', 1.5);
    end
    xlabel('空间频率 (lp/mm)');
    ylabel('MTF');
    title('MTF曲线与MTF50值');
    xlim([0, max(lpmm(mtf_filled > 0.1))]);
    ylim([0, 1.05]);
    grid on;
    legend('show', 'Location', 'northeast');
end
