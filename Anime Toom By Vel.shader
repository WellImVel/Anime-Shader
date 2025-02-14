Shader "Custom/VRChatShader"
{
    Properties
    {
        [Foldout(General Settings)]
        _MainTex ("Base Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _AlphaMap ("Alpha Map", 2D) = "white" {}
        _AlphaCutoff ("Alpha Cutoff", Range(0,1)) = 0.5
        _Cull ("Cull Mode", Range(0,2)) = 2 
        
        [Foldout(Toon Shader)] 
        [Toggle] _EnableToon ("Enable Toon Shader", Float) = 1
        _ToonShade ("Toon Shade Intensity", Range(0,1)) = 0.5
        _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
        _RimLightColor ("Rim Light Color", Color) = (1,1,1,1)
        _RimLightIntensity ("Rim Light Intensity", Range(0,1)) = 0.5
        
        [Foldout(Realistic Shader)] 
        [Toggle] _EnableRealistic ("Enable Realistic Shader", Float) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Foldout(Special Effects)]
        [Toggle] _EnableEmission ("Enable Emission", Float) = 1
        _EmissionTex1 ("Emission Texture 1", 2D) = "white" {}
        _EmissionTex2 ("Emission Texture 2", 2D) = "white" {}
        _EmissionTex3 ("Emission Texture 3", 2D) = "white" {}
        _EmissionTex4 ("Emission Texture 4", 2D) = "white" {}
        _EmissionColor1 ("Emission Color 1", Color) = (1,1,1,1)
        _EmissionColor2 ("Emission Color 2", Color) = (1,1,1,1)
        _EmissionColor3 ("Emission Color 3", Color) = (1,1,1,1)
        _EmissionColor4 ("Emission Color 4", Color) = (1,1,1,1)
        
        [Toggle] _EnableDissolve ("Enable Dissolve", Float) = 1
        _DissolveTex1 ("Dissolve Texture 1", 2D) = "white" {}
        _DissolveTex2 ("Dissolve Texture 2", 2D) = "white" {}
        _DissolveTex3 ("Dissolve Texture 3", 2D) = "white" {}
        _DissolveAmount1 ("Dissolve Amount 1", Range(0,1)) = 0.5
        _DissolveAmount2 ("Dissolve Amount 2", Range(0,1)) = 0.5
        _DissolveAmount3 ("Dissolve Amount 3", Range(0,1)) = 0.5
        
        [Toggle] _EnableGlitter ("Enable Glitter", Float) = 1
        _GlitterIntensity ("Glitter Intensity", Range(0,1)) = 0.5
        
        [Foldout(Rendering)] 
        [Enum(Opaque,0, Cutout,1, Fade,2, Transparent,3, Additive,4)] _RenderingMode ("Rendering Mode", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            Cull [_Cull]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile
            
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD1;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EnableToon, _ToonShade;
            float3 _ShadowColor;
            float3 _RimLightColor;
            float _RimLightIntensity;
            float _EnableRealistic, _Glossiness, _Metallic;
            float _Cull;
            
            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                if (_EnableToon > 0.5)
                {
                    float diff = max(dot(i.normal, float3(0,1,0)), 0.0);
                    col.rgb *= lerp(_ShadowColor.rgb, float3(1,1,1), smoothstep(0.3, 0.6, diff));
                    float rim = 1.0 - max(dot(i.normal, float3(0,0,1)), 0.0);
                    col.rgb += rim * _RimLightColor * _RimLightIntensity;
                }
                
                if (_EnableRealistic > 0.5)
                {
                    float3 lightDir = normalize(float3(0.5, 1, 0.5));
                    float diff = max(dot(i.normal, lightDir), 0.0);
                    float3 reflectDir = reflect(-lightDir, i.normal);
                    float spec = pow(max(dot(reflectDir, float3(0, 0, 1)), 0.0), _Glossiness * 128.0);
                    col.rgb = col.rgb * (0.5 + 0.5 * diff) + spec * _Metallic;
                }
                
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}