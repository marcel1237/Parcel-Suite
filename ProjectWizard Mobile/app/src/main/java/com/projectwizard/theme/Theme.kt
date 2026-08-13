package com.projectwizard.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color

enum class ThemeType {
    DRACULA,
    NORD_DARK,
    NORD_LIGHT,
    PRIMER_DARK,
    PRIMER_LIGHT,
    CUPERTINO_DARK,
    CUPERTINO_LIGHT
}

object ThemeManager {
    var currentTheme by mutableStateOf(ThemeType.PRIMER_DARK)
}

// 1. PRIMER DARK
val PrimerDarkColors = darkColorScheme(
    primary = Color(0xFF2188FF),
    onPrimary = Color.White,
    background = Color(0xFF0D1117),
    surface = Color(0xFF161B22),
    onBackground = Color(0xFFC9D1D9),
    onSurface = Color(0xFFC9D1D9),
    surfaceVariant = Color(0xFF21262D),
    onSurfaceVariant = Color(0xFF8B949E),
    secondary = Color(0xFF388BFD),
    outline = Color(0xFF30363D)
)

// 2. PRIMER LIGHT
val PrimerLightColors = lightColorScheme(
    primary = Color(0xFF0969DA),
    onPrimary = Color.White,
    background = Color(0xFFFFFFFF),
    surface = Color(0xFFF6F8FA),
    onBackground = Color(0xFF24292F),
    onSurface = Color(0xFF24292F),
    surfaceVariant = Color(0xFFECEFF2),
    onSurfaceVariant = Color(0xFF57606A),
    secondary = Color(0xFF0550AE),
    outline = Color(0xFFD0D7DE)
)

// 3. DRACULA
val DraculaColors = darkColorScheme(
    primary = Color(0xFFBD93F9),
    onPrimary = Color(0xFF282A36),
    background = Color(0xFF282A36),
    surface = Color(0xFF1E1F29),
    onBackground = Color(0xFFF8F8F2),
    onSurface = Color(0xFFF8F8F2),
    surfaceVariant = Color(0xFF44475A),
    onSurfaceVariant = Color(0xFF6272A4),
    secondary = Color(0xFFFF79C6),
    outline = Color(0xFF44475A)
)

// 4. NORD DARK
val NordDarkColors = darkColorScheme(
    primary = Color(0xFF88C0D0),
    onPrimary = Color(0xFF2E3440),
    background = Color(0xFF2E3440),
    surface = Color(0xFF3B4252),
    onBackground = Color(0xFFD8DEE9),
    onSurface = Color(0xFFECEFF4),
    surfaceVariant = Color(0xFF434C5E),
    onSurfaceVariant = Color(0xFFD8DEE9),
    secondary = Color(0xFF81A1C1),
    outline = Color(0xFF4C566A)
)

// 5. NORD LIGHT
val NordLightColors = lightColorScheme(
    primary = Color(0xFF5E81AC),
    onPrimary = Color.White,
    background = Color(0xFFECEFF4),
    surface = Color(0xFFE5E9F0),
    onBackground = Color(0xFF2E3440),
    onSurface = Color(0xFF3B4252),
    surfaceVariant = Color(0xFFD8DEE9),
    onSurfaceVariant = Color(0xFF4C566A),
    secondary = Color(0xFF81A1C1),
    outline = Color(0xFFD8DEE9)
)

// 6. CUPERTINO DARK
val CupertinoDarkColors = darkColorScheme(
    primary = Color(0xFF0A84FF),
    onPrimary = Color.White,
    background = Color(0xFF000000),
    surface = Color(0xFF1C1C1E),
    onBackground = Color(0xFFFFFFFF),
    onSurface = Color(0xFFE5E5EA),
    surfaceVariant = Color(0xFF2C2C2E),
    onSurfaceVariant = Color(0xFFAEAEB2),
    secondary = Color(0xFF30D158),
    outline = Color(0xFF3A3A3C)
)

// 7. CUPERTINO LIGHT
val CupertinoLightColors = lightColorScheme(
    primary = Color(0xFF007AFF),
    onPrimary = Color.White,
    background = Color(0xFFF2F2F7),
    surface = Color(0xFFFFFFFF),
    onBackground = Color(0xFF000000),
    onSurface = Color(0xFF1C1C1E),
    surfaceVariant = Color(0xFFE5E5EA),
    onSurfaceVariant = Color(0xFF3C3C43),
    secondary = Color(0xFF34C759),
    outline = Color(0xFFC7C7CC)
)

@Composable
fun getActiveColorScheme(): ColorScheme {
    return when (ThemeManager.currentTheme) {
        ThemeType.PRIMER_DARK -> PrimerDarkColors
        ThemeType.PRIMER_LIGHT -> PrimerLightColors
        ThemeType.DRACULA -> DraculaColors
        ThemeType.NORD_DARK -> NordDarkColors
        ThemeType.NORD_LIGHT -> NordLightColors
        ThemeType.CUPERTINO_DARK -> CupertinoDarkColors
        ThemeType.CUPERTINO_LIGHT -> CupertinoLightColors
    }
}
