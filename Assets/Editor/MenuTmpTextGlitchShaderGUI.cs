using System;
using UnityEditor;
using UnityEngine;

namespace ErrorX.Editor
{
    public sealed class MenuTmpTextGlitchShaderGUI : ShaderGUI
    {
        private static readonly string[] GlitchPropertyNames =
        {
            "_Intensity",
            "_StripFrequency",
            "_TriggerRate",
            "_ArtifactStrength",
            "_JitterSpeed",
            "_GrayscaleAmount",
        };

        private ShaderGUI _tmpGui;
        private bool _glitchFoldout = true;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            DrawTmpGui(materialEditor, properties);
            DrawGlitchSection(materialEditor, properties);
        }

        private void DrawTmpGui(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_tmpGui == null)
            {
                Type tmpGuiType = null;
                foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
                {
                    tmpGuiType = assembly.GetType("TMPro.EditorUtilities.TMP_SDFShaderGUI", throwOnError: false);
                    if (tmpGuiType != null)
                    {
                        break;
                    }
                }

                if (tmpGuiType != null && typeof(ShaderGUI).IsAssignableFrom(tmpGuiType))
                {
                    _tmpGui = (ShaderGUI)Activator.CreateInstance(tmpGuiType);
                }
            }

            if (_tmpGui != null)
            {
                _tmpGui.OnGUI(materialEditor, properties);
                return;
            }

            materialEditor.PropertiesDefaultGUI(properties);
        }

        private void DrawGlitchSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            var intensity = FindProperty("_Intensity", properties, false);
            if (intensity == null)
            {
                return;
            }

            EditorGUILayout.Space();
            _glitchFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_glitchFoldout, "Glitch Strip");
            if (_glitchFoldout)
            {
                EditorGUILayout.HelpBox("Row-based TMP glitch controls.", MessageType.None);

                foreach (var propertyName in GlitchPropertyNames)
                {
                    var property = FindProperty(propertyName, properties, false);
                    if (property != null)
                    {
                        materialEditor.ShaderProperty(property, property.displayName);
                    }
                }
            }

            EditorGUILayout.EndFoldoutHeaderGroup();
        }
    }
}
