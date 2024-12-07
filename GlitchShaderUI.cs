using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GlitchShaderUI : ShaderGUI
{
    bool VertexWobbleFoldout = false;
    bool VertexRoundingFoldout = false;
    bool EmissionFoldout = false;

    #region Custom UI Methods
    bool Foldout(string label, bool output, float indentLevel)
    {
        Rect controlRect = EditorGUILayout.GetControlRect();

        return EditorGUI.Foldout(new Rect(
            20 + (10 * (indentLevel)),
            controlRect.y,
            controlRect.width,
            controlRect.height
            ), output, label);
    }
    #endregion

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // setup
        Material material = materialEditor.target as Material;

        // glossiness slider
        MaterialProperty _Glossiness = FindProperty("_Glossiness", properties);
        materialEditor.RangeProperty(_Glossiness, "Smoothness");

        // metallic slider
        MaterialProperty _Metallic = FindProperty("_Metallic", properties);
        materialEditor.RangeProperty(_Metallic, "Metallic");

        // color
        MaterialProperty _Color = FindProperty("_Color", properties);
        materialEditor.ColorProperty(_Color, "Color");

        MaterialProperty _MainTex = FindProperty("_MainTex", properties);
        materialEditor.TextureProperty(_MainTex, "Base Texture");

        #region Vertex Rounding
        //VertexRoundingFoldout = Foldout("Vertex Rounding (PS1 'Shaky' Effect)", VertexRoundingFoldout, 0);
        if (VertexRoundingFoldout)
        {
            MaterialProperty _UseVertexRounding = FindProperty("_UseVertexRounding", properties);
            materialEditor.ShaderProperty(_UseVertexRounding, "Use Vertex Rounding");

            MaterialProperty _VertexRoundingFactor = FindProperty("_VertexRoundingFactor", properties);
            materialEditor.RangeProperty(_VertexRoundingFactor, "Vertex Rounding Factor");
        }
        #endregion

        #region Vertex Wobble
        VertexWobbleFoldout = Foldout("Vertex Wobble", VertexWobbleFoldout, 0);
        if (VertexWobbleFoldout)
        {
            MaterialProperty _UseVertexWobble = FindProperty("_UseVertexWobble", properties);
            materialEditor.ShaderProperty(_UseVertexWobble, "Use Vertex Wobble");

            MaterialProperty _VertexWobble = FindProperty("_VertexWobble", properties);
            materialEditor.VectorProperty(_VertexWobble, "Vertex Wobble");

            MaterialProperty _WobbleFrequency = FindProperty("_WobbleFrequency", properties);
            materialEditor.VectorProperty(_WobbleFrequency, "Wobble Frequency");

            MaterialProperty _WobbleSpeed = FindProperty("_WobbleSpeed", properties);
            materialEditor.FloatProperty(_WobbleSpeed, "Wobble Speed");
        }
        #endregion

        #region Emission
        EmissionFoldout = Foldout("Emission Properties", EmissionFoldout, 0);
        if (EmissionFoldout)
        {
            MaterialProperty _UseEmission = FindProperty("_UseEmission", properties);
            materialEditor.ShaderProperty(_UseEmission, "Use Emission");

            MaterialProperty _Emission_Color = FindProperty("_Emission_Color", properties);
            materialEditor.ColorProperty(_Emission_Color, "Emission Color");

            MaterialProperty _Emission_Strength = FindProperty("_Emission_Strength", properties);
            materialEditor.FloatProperty(_Emission_Strength, "Emission Strength");

            MaterialProperty _Emission_Tex = FindProperty("_Emission_Tex", properties);
            materialEditor.TextureProperty(_Emission_Tex, "Emission Texture");

            MaterialProperty _Emission_Pulse = FindProperty("_Emission_Pulse", properties);
            materialEditor.ShaderProperty(_Emission_Pulse, "Emission Pulse");

            MaterialProperty _Emission_Pulse_Min = FindProperty("_Emission_Pulse_Min", properties);
            materialEditor.RangeProperty(_Emission_Pulse_Min, "Emission Pulse Minimum");

            MaterialProperty _Emission_Pulse_Speed = FindProperty("_Emission_Pulse_Speed", properties);
            materialEditor.RangeProperty(_Emission_Pulse_Speed, "Emission Pulse Speed");
        }
        #endregion

        #region Shader Feature Toggling
        // vertex wobble keyword
        if (FindProperty("_UseVertexWobble", properties).floatValue == 1f)
        {
            material.EnableKeyword("_VERTEX_WOBBLE");
        } else
        {
            material.DisableKeyword("_VERTEX_WOBBLE");
        }

        // emission keyword
        if (FindProperty("_UseEmission", properties).floatValue == 1f)
        {
            material.EnableKeyword("_USE_EMISSION");
        } else
        {
            material.DisableKeyword("_USE_EMISSION");
        }

        // vertex rounding keyword
        if (FindProperty("_UseVertexRounding", properties).floatValue == 1f)
        {
            material.EnableKeyword("_VERTEX_ROUNDING");
        } else
        {
            material.DisableKeyword("_VERTEX_ROUNDING");
        }
        #endregion
    }
}
