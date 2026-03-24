@{
    ModuleVersion     = '1.0.0'
    GUID              = 'a3f2c1d4-5e6b-7890-abcd-ef1234567890'
    Author            = 'lycomedes1814'
    Description       = 'Converts a YouTube playlist to a single M4B audiobook file with chapters and cover art.'
    PowerShellVersion = '5.1'
    RootModule        = 'ConvertYtPlaylistToM4b.psm1'
    FunctionsToExport = @('Convert-YtPlaylistToM4b')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('youtube', 'audiobook', 'm4b', 'yt-dlp', 'ffmpeg')
        }
    }
}
