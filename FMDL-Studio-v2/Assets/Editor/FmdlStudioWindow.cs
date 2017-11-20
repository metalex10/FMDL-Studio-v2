﻿using UnityEditor;
using UnityEngine;

public class FmdlStudioWindow : EditorWindow
{
    [MenuItem("FMDL Studio/Import FMDL", false, 0)]
    public static void ImportFMDLOption()
    {
        //FmdlStudioWindow fmdlWindow = (FmdlStudioWindow)CreateInstance("FmdlStudioWindow");

        string windowPath = EditorUtility.OpenFilePanel("Select FMDL", "", "fmdl");
        FmdlImporter.FMDLRead(windowPath);

        UnityEngine.Debug.Log("Selected FMDL: " + windowPath);
    } //ImportFMDLOption

    [MenuItem("FMDL Studio/Convert to FBX", false, 1)]
    public static void ExportFBXOption()
    {
        if (Selection.activeGameObject != null)
        {
            string filePath = EditorUtility.SaveFilePanel("Export To FBX", "", Selection.activeGameObject.name, "fbx");

            if (!string.IsNullOrWhiteSpace(filePath))
                FBXConverter.ConvertToFBX(Selection.activeGameObject, filePath);
            else
                Debug.Log("No path selected.");
        } //if
        else
            Debug.Log("No objects selected.");
    } //ExportFBXOption

    [MenuItem("FMDL Studio/Export FMDL", false, 2)]
    public static void ExportFMDLOption()
    {
        if (Selection.activeGameObject != null)
        {
            string windowPath = EditorUtility.SaveFilePanel("Export To FMDL", "", Selection.activeGameObject.name, "fmdl");
            FmdlExporter.FMDLWrite(windowPath);
        }
        else
            Debug.Log("No path selected.");
        UnityEngine.Debug.Log("Selected FMDL Name: ");
    } //ImportFMDLOption

    [MenuItem("FMDL Studio/Set Texture Folder", false, 100)]
    public static void SetTextureFolder()
    {
        string windowPath = EditorUtility.OpenFolderPanel("Select Texture Folder", "", "");

        if (!string.IsNullOrEmpty(windowPath))
        {
            Globals.WriteTexturePath(windowPath);
        } //if
        else
            Debug.Log("No folder selected.");
    } //ImportFMDLOption
} //class