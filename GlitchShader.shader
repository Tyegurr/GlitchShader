Shader "Tyegurr/GlitchShader"
{
    Properties
    {
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        // vertex wobble
        [Toggle] _UseVertexWobble ("Use Vertex Wobble", Int) = 0
        _VertexWobble ("Vertex Wobble", Vector) = (0, 0, 0, 0)
        _WobbleFrequency ("Wobble Frequency", Vector) = (0, 0, 0, 0)
        _WobbleSpeed ("Wobble Speed", Float) = 0

        // emission
        [Toggle] _UseEmission ("Use Emission", Int) = 0
        _Emission_Color ("Emission Color", Color) = (0, 0, 0, 1)
        _Emission_Strength ("Emission Strength", Float) = 1
        _Emission_Tex ("Emission Texture", 2D) = "white" {}
        [Toggle] _Emission_Pulse ("Emission Pulse", Int) = 0
        _Emission_Pulse_Min ("Emission Pulse Minimum", Range(0, 1)) = 0.2
        _Emission_Pulse_Speed ("Emission Pulse Speed", Range(0, 10)) = 0

        [Toggle] _UseVertexRounding ("Use Vertex Rounding", Int) = 0
        _VertexRoundingFactor ("Vertex Rounding Factor", Range(1, 1024)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.5 target, to get nicer looking lighting
        #pragma target 3.5

        #pragma multi_compile _ _VERTEX_WOBBLE
        #pragma multi_compile _ _USE_EMISSION
        #pragma multi_compile _ _VERTEX_ROUNDING

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;

            float2 uv_Emission_Tex;

            float3 tangentSpaceCameraPos;
            float3 tangentSpacePos;
            float2 texcoord;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // vertex wobble
        bool _UseVertexWobble;
        #ifdef _VERTEX_WOBBLE
        half4 _VertexWobble;
        half4 _WobbleFrequency;
        half _WobbleSpeed;
        #endif

        // vertex rounding
        bool _UseVertexRounding;
        #ifdef _VERTEX_ROUNDING
        float _VertexRoundingFactor;
        #endif

        // emission
        bool _UseEmission;
        #ifdef _USE_EMISSION
        float4 _Emission_Color;
        float _Emission_Strength;
        sampler2D _Emission_Tex;
        bool _Emission_Pulse;
        float _Emission_Pulse_Min;
        float _Emission_Pulse_Speed;
        #endif

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 localPos = mul(unity_WorldToObject, v.vertex).xyz;

            #ifdef _VERTEX_WOBBLE
            v.vertex.x += sin(localPos.x * _WobbleFrequency.x + _Time.y * _WobbleSpeed) * _VertexWobble.x; // offset is insane. fix
            v.vertex.y += sin(worldPos.x * _WobbleFrequency.y + _Time.y * _WobbleSpeed) * _VertexWobble.y;
            v.vertex.z += sin(worldPos.x * _WobbleFrequency.z + _Time.y * _WobbleSpeed) * _VertexWobble.z;
            #endif

            #ifdef _VERTEX_ROUNDING
            /*float og_vertX = v.vertex.x;

            float vertX_Rounded = (floor(localPos.x * _VertexRoundingFactor) / _VertexRoundingFactor) / 2 + worldPos.x / 2;
            float vertY_Rounded = (floor(localPos.y * _VertexRoundingFactor) / _VertexRoundingFactor) / 2 + worldPos.y / 2;
            v.vertex.x = vertX_Rounded;
            v.vertex.y = vertY_Rounded;*/ //TODO: bugged
            #endif
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 combinedAlbedo = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            // emission
            #ifdef _USE_EMISSION
            fixed4 emissionColor = tex2D(_Emission_Tex, IN.uv_Emission_Tex) * _Emission_Color;
            if (_Emission_Pulse)
            {
                emissionColor *= _Emission_Pulse_Min + (abs(sin(_Time.y * _Emission_Pulse_Speed)) / 2) * _Emission_Strength;

                combinedAlbedo += emissionColor;
            } else {
                combinedAlbedo += emissionColor * _Emission_Strength;
            }

            
            #endif

            o.Albedo = combinedAlbedo.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = combinedAlbedo.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
    CustomEditor "GlitchShaderUI"
}
