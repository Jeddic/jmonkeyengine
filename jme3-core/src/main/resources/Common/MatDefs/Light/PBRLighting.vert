#import "Common/ShaderLib/Instancing.glsllib"
#import "Common/ShaderLib/Skinning.glsllib"

uniform vec4 m_BaseColor;

uniform vec4 g_AmbientLightColor;
varying vec2 texCoord;

#ifdef SEPARATE_TEXCOORD
  varying vec2 texCoord2;
  attribute vec2 inTexCoord2;
#endif

varying vec4 Color;

attribute vec3 inPosition;
attribute vec2 inTexCoord;
attribute vec3 inNormal;

#ifdef VERTEX_COLOR
  attribute vec4 inColor;
#endif

varying vec3 wNormal;
varying vec3 wPosition;
#ifdef NORMALMAP
    attribute vec4 inTangent;
    varying vec3 wTangent;
    varying vec3 wBinormal;
#endif

void main(){
    vec4 modelSpacePos = vec4(inPosition, 1.0);
    vec3 modelSpaceNorm = inNormal;

    #if  defined(NORMALMAP) && !defined(VERTEX_LIGHTING)
         vec3 modelSpaceTan  = inTangent.xyz;
    #endif

    #ifdef NUM_BONES
         #if defined(NORMALMAP) && !defined(VERTEX_LIGHTING)
         Skinning_Compute(modelSpacePos, modelSpaceNorm, modelSpaceTan);
         #else
         Skinning_Compute(modelSpacePos, modelSpaceNorm);
         #endif
    #endif

    gl_Position = TransformWorldViewProjection(modelSpacePos);
    texCoord = inTexCoord;
    #ifdef SEPARATE_TEXCOORD
       texCoord2 = inTexCoord2;
    #endif

    wPosition = TransformWorld(modelSpacePos).xyz;
    wNormal  = TransformWorld(vec4(modelSpaceNorm,0.0)).xyz;
       
    #if defined(NORMALMAP) 
      wTangent = TransformWorld(vec4(modelSpaceTan,0.0)).xyz;
      wBinormal = cross(wNormal, wTangent)* inTangent.w;            
    #endif

    Color = m_BaseColor;
    
    #ifdef VERTEX_COLOR                    
        Color *= inColor;
    #endif
}