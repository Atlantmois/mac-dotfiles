// ============================================================================
//  Neovide 风格光标轨迹 (cursor warp) —— Ghostty 自定义着色器
// ----------------------------------------------------------------------------
//  效果：光标在两点间移动时，光标矩形会被"拉长"成一条残影并在 DURATION 内
//        收缩回新位置。这正是 Neovide 的 cursor animation 观感。
//
//  上游：sahaj-b/ghostty-cursor-shaders —— cursor_warp.glsl (MIT License)
//        https://github.com/sahaj-b/ghostty-cursor-shaders
//  依赖：Ghostty 自定义着色器 uniform（iCurrentCursor / iPreviousCursor /
//        iTimeCursorChange / iCurrentCursorColor），均需 Ghostty >= 1.2。
//
//  启用方式（在 ghostty config 中）：
//      custom-shader = shaders/cursor_warp.glsl
//      custom-shader-animation = true
//
//  调参：改下面的「可调参数」区即可，改完在 Ghostty 里 Ctrl+Shift+, 重载配置。
// ============================================================================

// sRGB -> Linear（Ghostty 传进来的是 sRGB，着色器管线在 linear 空间工作）
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// ============================== 可调参数 ====================================

// 轨迹颜色。默认跟随光标颜色；若光标色接近纯黑（在深色背景上看不见）则
// 自动回退到前景色，alpha 为 0 时补到 0.65，避免"配好了却看不到"。
// 想用固定颜色就整行替换为（记得用 sRGBToLinear 包一层，否则偏亮）：
//     vec4 TRAIL_COLOR = vec4(sRGBToLinear(vec3(0.20, 0.60, 1.00)), 0.55);
vec4 TRAIL_COLOR = vec4(
    sRGBToLinear(dot(iCurrentCursorColor.rgb, vec3(0.2126, 0.7152, 0.0722)) < 0.02
                     ? iForegroundColor
                     : iCurrentCursorColor.rgb),
    max(iCurrentCursorColor.a, 0.65));

const float DURATION = 0.2;               // 整段动画时长(秒)。调大 = 拖影更明显、更"黏"
const float TRAIL_SIZE = 0.8;             // 0.0 = 四角同步移动(整块平移)；1.0 = 最大拉丝
const float THRESHOLD_MIN_DISTANCE = 0.8; // 触发轨迹的最小位移，单位=光标高度。
                                          // 移动一行正好是 1.0，所以默认的 1.5 会让逐行移动完全没轨迹，
                                          // 只有 G/gg/Ctrl-D 这类大跳才有。0.8 = 逐行也出轨迹；
                                          // 横向逐字移动只有约 0.4，仍不会误触发。
const float BLUR = 1.0;                   // 边缘羽化/抗锯齿(像素)
const float TRAIL_THICKNESS = 1.0;        // 轨迹厚度：1.0=与光标等高，<1 更细
const float TRAIL_THICKNESS_X = 0.9;      // 轨迹宽度比例

const float FADE_ENABLED = 0.0;           // 1.0 = 轨迹从头到尾渐隐；0.0 = 实心
const float FADE_EXPONENT = 5.0;          // 渐隐曲线指数（仅 FADE_ENABLED=1 时生效）

// ============================ 缓动函数 ======================================
// 只保留一个 ease()：默认 EaseOutCirc。想要别的观感，把下面注释里的函数
// 换上来（同名 ease 只能留一个生效）。

// // Linear
// float ease(float x) { return x; }
// // EaseOutQuad
// float ease(float x) { return 1.0 - (1.0 - x) * (1.0 - x); }
// // EaseOutCubic
// float ease(float x) { return 1.0 - pow(1.0 - x, 3.0); }
// // EaseOutQuart
// float ease(float x) { return 1.0 - pow(1.0 - x, 4.0); }
// // EaseOutQuint
// float ease(float x) { return 1.0 - pow(1.0 - x, 5.0); }
// // EaseOutSine
// float ease(float x) { return sin((x * PI) / 2.0); }
// // EaseOutExpo
// float ease(float x) { return x == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * x); }

// EaseOutCirc —— 默认：起步快、收尾稳，最接近 Neovide 的手感
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

// // EaseOutBack（回弹）
// float ease(float x) {
//     const float C1_BACK = 1.70158;
//     const float C3_BACK = C1_BACK + 1.0;
//     return 1.0 + C3_BACK * pow(x - 1.0, 3.0) + C1_BACK * pow(x - 1.0, 2.0);
// }
// // EaseOutElastic（弹性）
// float ease(float x) {
//     const float PI = 3.14159265359;
//     const float C4_ELASTIC = (2.0 * PI) / 3.0;
//     return x == 0.0 ? 0.0
//          : x == 1.0 ? 1.0
//                     : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * C4_ELASTIC) + 1.0;
// }
// // Parametric Spring（弹簧）
// float ease(float x) {
//     const float SPRING_STIFFNESS = 9.0;
//     const float SPRING_DAMPING = 0.9;
//     x = clamp(x, 0.0, 1.0);
//     float decay = exp(-SPRING_DAMPING * SPRING_STIFFNESS * x);
//     float freq = sqrt(SPRING_STIFFNESS * (1.0 - SPRING_DAMPING * SPRING_DAMPING));
//     float osc = cos(freq * 6.283185 * x) + (SPRING_DAMPING * sqrt(SPRING_STIFFNESS) / freq) * sin(freq * 6.283185 * x);
//     return 1.0 - decay * osc;
// }

// ============================ 几何工具 ======================================
// 参考 Inigo Quilez 的 2D 距离函数：https://iquilezles.org/articles/distfunctions2d/

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfConvexQuad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);

    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance, float blurAmount) {
    return 1. - smoothstep(0., normalize(vec2(blurAmount, blurAmount), 0.).x, distance);
}

// 按「角点与移动方向的对齐程度」决定动画时长。
// dot_val ∈ [-2, 2]：> 0.5 前导角；> -0.5 侧边角；<= -0.5 拖尾角
float getDurationFromDot(float dot_val, float DURATION_LEAD, float DURATION_SIDE, float DURATION_TRAIL) {
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);

    float duration = mix(DURATION_TRAIL, DURATION_SIDE, isSide);
    duration = mix(duration, DURATION_LEAD, isLead);
    return duration;
}

// ============================== 主体 ========================================

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // 归一化到以 y 为基准的坐标系
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 halfSizeCC = currentCursor.zw * 0.5;
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);
    vec2 halfSizeCP = previousCursor.zw * 0.5;

    // 当前光标位置挖洞用
    float sdfCurrentCursor = getSdfRectangle(vu, centerCC, halfSizeCC);

    float lineLength = distance(centerCC, centerCP);
    float minDist = currentCursor.w * THRESHOLD_MIN_DISTANCE;

    vec4 newColor = vec4(fragColor);

    // 距离上次光标变动过去了多久
    float baseProgress = iTime - iTimeCursorChange;

    // 位移够大 且 动画还没结束 —— 注意这里用 uniform 分支，同屏所有像素走同一分支，无发散开销
    if (lineLength > minDist && baseProgress < DURATION - 0.001) {
        // ---- 当前光标的四角（按 TRAIL_THICKNESS 缩放）----
        float cc_half_height = currentCursor.w * 0.5;
        float cc_center_y = currentCursor.y - cc_half_height;
        float cc_new_half_height = cc_half_height * TRAIL_THICKNESS;
        float cc_new_top_y = cc_center_y + cc_new_half_height;
        float cc_new_bottom_y = cc_center_y - cc_new_half_height;

        float cc_half_width = currentCursor.z * 0.5;
        float cc_center_x = currentCursor.x + cc_half_width;
        float cc_new_half_width = cc_half_width * TRAIL_THICKNESS_X;
        float cc_new_left_x = cc_center_x - cc_new_half_width;
        float cc_new_right_x = cc_center_x + cc_new_half_width;

        vec2 cc_tl = vec2(cc_new_left_x, cc_new_top_y);
        vec2 cc_tr = vec2(cc_new_right_x, cc_new_top_y);
        vec2 cc_bl = vec2(cc_new_left_x, cc_new_bottom_y);
        vec2 cc_br = vec2(cc_new_right_x, cc_new_bottom_y);

        // ---- 上一帧光标的四角 ----
        float cp_half_height = previousCursor.w * 0.5;
        float cp_center_y = previousCursor.y - cp_half_height;
        float cp_new_half_height = cp_half_height * TRAIL_THICKNESS;
        float cp_new_top_y = cp_center_y + cp_new_half_height;
        float cp_new_bottom_y = cp_center_y - cp_new_half_height;

        float cp_half_width = previousCursor.z * 0.5;
        float cp_center_x = previousCursor.x + cp_half_width;
        float cp_new_half_width = cp_half_width * TRAIL_THICKNESS_X;
        float cp_new_left_x = cp_center_x - cp_new_half_width;
        float cp_new_right_x = cp_center_x + cp_new_half_width;

        vec2 cp_tl = vec2(cp_new_left_x, cp_new_top_y);
        vec2 cp_tr = vec2(cp_new_right_x, cp_new_top_y);
        vec2 cp_bl = vec2(cp_new_left_x, cp_new_bottom_y);
        vec2 cp_br = vec2(cp_new_right_x, cp_new_bottom_y);

        // ---- 逐角计算时长：前导角先到，拖尾角后到 => 形状被"拉长" ----
        const float DURATION_TRAIL = DURATION;
        const float DURATION_LEAD = DURATION * (1.0 - TRAIL_SIZE);
        const float DURATION_SIDE = (DURATION_LEAD + DURATION_TRAIL) / 2.0;

        vec2 moveVec = centerCC - centerCP;
        vec2 s = sign(moveVec);

        float dot_tl = dot(vec2(-1., 1.), s);
        float dot_tr = dot(vec2(1., 1.), s);
        float dot_bl = dot(vec2(-1., -1.), s);
        float dot_br = dot(vec2(1., -1.), s);

        float dur_tl = getDurationFromDot(dot_tl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_tr = getDurationFromDot(dot_tr, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_bl = getDurationFromDot(dot_bl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_br = getDurationFromDot(dot_br, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        // 水平移动时，把左右两条"边"上的角点时长统一，避免边缘抖动
        float isMovingRight = step(0.5, s.x);
        float isMovingLeft = step(0.5, -s.x);

        float dot_right_edge = (dot_tr + dot_br) * 0.5;
        float dur_right_rail = getDurationFromDot(dot_right_edge, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        float dot_left_edge = (dot_tl + dot_bl) * 0.5;
        float dur_left_rail = getDurationFromDot(dot_left_edge, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        float final_dur_tl = mix(dur_tl, dur_left_rail, isMovingLeft);
        float final_dur_bl = mix(dur_bl, dur_left_rail, isMovingLeft);

        float final_dur_tr = mix(dur_tr, dur_right_rail, isMovingRight);
        float final_dur_br = mix(dur_br, dur_right_rail, isMovingRight);

        // 每个角点各自的动画进度
        float prog_tl = ease(clamp(baseProgress / final_dur_tl, 0.0, 1.0));
        float prog_tr = ease(clamp(baseProgress / final_dur_tr, 0.0, 1.0));
        float prog_bl = ease(clamp(baseProgress / final_dur_bl, 0.0, 1.0));
        float prog_br = ease(clamp(baseProgress / final_dur_br, 0.0, 1.0));

        // 角点从"上一帧位置"插值到"当前位置"
        vec2 v_tl = mix(cp_tl, cc_tl, prog_tl);
        vec2 v_tr = mix(cp_tr, cc_tr, prog_tr);
        vec2 v_br = mix(cp_br, cc_br, prog_br);
        vec2 v_bl = mix(cp_bl, cc_bl, prog_bl);

        // ---- 用四边形 SDF 画出这条残影 ----
        float sdfTrail = getSdfConvexQuad(vu, v_tl, v_tr, v_br, v_bl);

        // ---- 沿轨迹方向的渐隐 ----
        vec2 fragVec = vu - centerCP;
        // 0.0 = 尾部，1.0 = 头部
        float fadeProgress = clamp(dot(fragVec, moveVec) / (dot(moveVec, moveVec) + 1e-6), 0.0, 1.0);

        vec4 trail = TRAIL_COLOR;

        // 注意：上游此处的内层 effectiveBlur 遮蔽了外层同名变量，等价于
        // 永远使用 BLUR。此处保持上游行为不变，以免引入未经验证的观感变化。
        float effectiveBlur = BLUR;
        if (BLUR < 2.5) {
            float isDiagonal = abs(s.x) * abs(s.y); // 斜向=1.0，横竖=0.0
            float effectiveBlur = mix(0.0, BLUR, isDiagonal);
        }
        float shapeAlpha = antialising(sdfTrail, effectiveBlur);

        if (FADE_ENABLED > 0.5) {
            float easedProgress = pow(fadeProgress, FADE_EXPONENT);
            trail.a *= easedProgress;
        }

        float finalAlpha = trail.a * shapeAlpha;

        // 保留原背景 alpha，避免破坏窗口透明/模糊
        newColor = mix(newColor, vec4(trail.rgb, newColor.a), finalAlpha);

        // 在残影上挖个洞，让真正的光标始终画在最上层
        newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));
    }

    fragColor = newColor;
}
