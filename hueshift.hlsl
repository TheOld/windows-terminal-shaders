// This shader applies a hue shift.

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
	float  Time;
	float  Scale;
	float2 Resolution;
	float4 Background;
};

#define HUE_OFFSET 0.0f
#define CHANGE_RATE 0.1f

float3 rgb_to_hsv_no_clip(float3 RGB)
{
	float3 HSV;
    
	float minChannel, maxChannel;
	if (RGB.r > RGB.g) {
		maxChannel = RGB.r;
		minChannel = RGB.g;
 	} else {
  		maxChannel = RGB.g;
  		minChannel = RGB.r;
 	}
 
 	if (RGB.b > maxChannel) maxChannel = RGB.b;
 	if (RGB.b < minChannel) minChannel = RGB.b;
    
    HSV.xy = 0;
    HSV.z = maxChannel;
    float delta = maxChannel - minChannel;             //Delta RGB value 
    if (delta != 0) {                    // If gray, leave H & S at zero
       HSV.y = delta / HSV.z;
       float3 delRGB;
       delRGB = (HSV.zzz - RGB + 3*delta) / (6.0*delta);
       if      ( RGB.r == HSV.z ) HSV.x = delRGB.b - delRGB.g;
       else if ( RGB.g == HSV.z ) HSV.x = ( 1.0/3.0) + delRGB.r - delRGB.b;
       else if ( RGB.b == HSV.z ) HSV.x = ( 2.0/3.0) + delRGB.g - delRGB.r;
    }
    return (HSV);
}

float3 hsv_to_rgb(float3 HSV)
{
    float3 RGB = HSV.z;
	float var_h = HSV.x * 6;
	float var_i = floor(var_h);
	float var_1 = HSV.z * (1.0 - HSV.y);
	float var_2 = HSV.z * (1.0 - HSV.y * (var_h-var_i));
	float var_3 = HSV.z * (1.0 - HSV.y * (1-(var_h-var_i)));
	if      (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
	else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
	else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
	else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
	else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
	else                 { RGB = float3(HSV.z, var_1, var_2); }
   return (RGB);
}

float4 main(float4 pos : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
 	float4 color = shaderTexture.Sample(samplerState, uv);
	float3 hsv = rgb_to_hsv_no_clip(color.rgb);
	hsv.x = fmod(hsv.r + HUE_OFFSET + Time * CHANGE_RATE, 1);

    return float4(hsv_to_rgb(hsv), color.a);
}
