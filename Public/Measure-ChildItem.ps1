function Measure-ChildItem {
    <#
    .SYNOPSIS
        Recursively measures the size of a directory.
    .DESCRIPTION
        Recursively measures the size of a directory.

        Measure-ChildItem uses  win32 functions, returning a minimal amount of information to gain speed. Once started, the operation cannot be interrupted by using Control and C. The more items present in a directory structure the longer this command will take.

        This command supports paths longer than 260 characters.
    .EXAMPLE
        Measure-ChildItem

        Get the size of all items within the current directory.
    .EXAMPLE
        Get-ChildItem c:\users | Measure-ChildItem -Unit MB

        Get the size of all child items of c:\users.
    .EXAMPLE
        Measure-ChildItem c:\windows -ValueOnly -Unit GB

        Return the size of the c:\windows directory and return only the size in GB.
    .EXAMPLE
        Get-ChildItem \\server\share -Directory | Measure-ChildItem -Unit TB -Digits 5

        Return the size of all items in a share.
    #>

    [CmdletBinding()]
    param (
        # The path to measure the size of. Accepts pipeline input. By default the size of the current working directory is measured.
        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String]$Path = $pwd,

        # The units sizes should be displayed in. By default, sizes are displayed in Bytes.
        [ValidateSet('B', 'KB', 'MB', 'GB', 'TB')]
        [String]$Unit = 'B',

        # When rounding, the number of digits to display after a decimal point. By defaut sizes are rounded to two decimal places.
        [ValidateRange(0, 28)]
        [Int32]$Digits = 2,

        # Return the size value only, discards file, and directory counts and path information.
        [Switch]$ValueOnly
    )

    begin {
        if (-not ('SC.IO.FileSearcher' -as [Type])) {
            Add-Type '
                using System;
                using System.Collections.Generic;
                using System.IO;
                using System.Runtime.InteropServices;

                namespace SC.IO
                {
                    [StructLayout(LayoutKind.Sequential)]
                    public struct FILETIME
                    {
                        public uint dwLowDateTime;
                        public uint dwHighDateTime;
                    };

                    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
                    public struct WIN32_FIND_DATA
                    {
                        public FileAttributes dwFileAttributes;
                        public FILETIME ftCreationTime;
                        public FILETIME ftLastAccessTime;
                        public FILETIME ftLastWriteTime;
                        public int nFileSizeHigh;
                        public int nFileSizeLow;
                        public int dwReserved0;
                        public int dwReserved1;
                        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
                        public string cFileName;
                        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 14)]
                        public string cAlternate;
                    }

                    public class UnsafeNativeMethods
                    {
                        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
                        public static extern IntPtr FindFirstFile(string lpFileName, out WIN32_FIND_DATA lpFindFileData);

                        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
                        public static extern IntPtr FindFirstFileExW(
                            string              lpFileName,
                            int                 fInfoLevelId,
                            out WIN32_FIND_DATA lpFindFileData,
                            int                 fSearchOp,
                            IntPtr              lpSearchFilter,
                            int                 dwAdditionalFlags
                        );

                        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
                        public static extern bool FindNextFile(IntPtr hFindFile, out WIN32_FIND_DATA lpFindFileData);

                        [DllImport("kernel32.dll", SetLastError = true)]
                        [return: MarshalAs(UnmanagedType.Bool)]
                        public static extern bool FindClose(IntPtr hFindFile);
                    }

                    public class FileSearcher
                    {
                        public static long[] MeasureItem(string path, bool recurse, long[] itemData)
                        {
                            if (itemData == null)
                            {
                                itemData = new long[]{ 0, 0, 0 };
                            }

                            string searchPath;
                            if (path.StartsWith(@"\\"))
                            {
                                searchPath = String.Format(@"\\?\UNC\{0}\*", path.Substring(2));
                            }
                            else
                            {
                                searchPath = String.Format(@"\\?\{0}\*", path);
                            }

                            WIN32_FIND_DATA findData = new WIN32_FIND_DATA();
                            IntPtr findHandle = UnsafeNativeMethods.FindFirstFileExW(searchPath, 1, out findData, 0, IntPtr.Zero, 0);
                            do
                            {
                                if (findData.dwFileAttributes.HasFlag(FileAttributes.Directory))
                                {
                                    if (recurse && findData.cFileName != "." && findData.cFileName != "..")
                                    {
                                        itemData[2]++;
                                        itemData = MeasureItem(
                                            Path.Combine(path, findData.cFileName),
                                            recurse,
                                            itemData
                                        );
                                    }
                                }
                                else
                                {
                                    itemData[0] += ((long)findData.nFileSizeHigh * UInt32.MaxValue) + (long)findData.nFileSizeLow;
                                    itemData[1]++;
                                }
                            } while (UnsafeNativeMethods.FindNextFile(findHandle, out findData));
                            UnsafeNativeMethods.FindClose(findHandle);

                            return itemData;
                        }
                    }
                }
            '
        }

        $power = ('B', 'KB', 'MB', 'GB', 'TB').IndexOf($Unit.ToUpper())
        $denominator = [Math]::Pow(1024, $power)
    }

    process {
        $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path).TrimEnd('\')

        $itemData = [SC.IO.FileSearcher]::MeasureItem($Path, $true, $null)

        if ($ValueOnly) {
            [Math]::Round(($itemData[0] / $denominator), $Digits)
        } else {
            [PSCustomObject]@{
                Path           = $Path
                Size           = [Math]::Round(($itemData[0] / $denominator), $Digits)
                FileCount      = $itemData[1]
                DirectoryCount = $itemData[2]
            }
        }
    }
}