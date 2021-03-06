﻿Shader "Custom/TestSpecularShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", float) = 10
	}
	SubShader {
	
		Tags{"LightMode" = "ForwardBase"}
		Pass{
		
			CGPROGRAM
			#pragma vertex vertexFunction
			#pragma fragment fragmentFunction
			
			//userDefined variables
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
				//light color for the shader
			uniform float4 _LightColor0;
			
			//unity defined variables
			
			//input struct
			struct inputStruct
			{
				float4 vertexPos: POSITION;
				float3 vertexNormal : NORMAL;
				
			};
		
			//output struct
			struct outputStruct
			{
				float4 pixelPos: SV_POSITION;
				float4 pixelCol: COLOR;
				
				float3 normalDirection: TEXCOORD0;
				float4 pixelWorldPos: TEXCOORD1;
			};
			
			//vertex program
			outputStruct vertexFunction(inputStruct input)
			{
				outputStruct toReturn;

				float3 normalDirection = normalize(mul(float4(input.vertexNormal,0.0), _World2Object).xyz);
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.vertexPos).xyz));

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float attenuation = 1.0;

				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));

				float3 specularReflection = reflect(-lightDirection, normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(normalDirection, lightDirection)) * specularReflection;

				float3 finalLight = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT;

				toReturn.pixelCol = float4(finalLight * _Color, 1.0);
				
				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				
				toReturn.normalDirection = input.vertexNormal;
				toReturn.pixelWorldPos = mul(input.vertexPos, _World2Object) ;
				
				return toReturn;
			}
			
			//fragment program
			float4 fragmentFunction(outputStruct input) : COLOR
			{
				float3 normalDirection = normalize(mul(float4(input.normalDirection,0.0), _World2Object).xyz);
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.pixelWorldPos).xyz));
				
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float attenuation = 1.0;
				
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
								
				float3 specularReflection = reflect(-lightDirection, normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(normalDirection, lightDirection)) * specularReflection;
				
				float3 finalLight = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
			
				//return input.pixelCol;//float4(finalLight * _Color, 1.0)
				return float4(finalLight * _Color, 1.0);
			}
			ENDCG
		}
	} 
	//Fallback
	//FallBack "Diffuse"
}
