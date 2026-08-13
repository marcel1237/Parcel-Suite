package com.projectwizard.view

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.graphics.Color
import com.projectwizard.theme.ThemeManager

object SyntaxHighlighter {

    private val javaKeywords = setOf(
        "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const",
        "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally", "float",
        "for", "goto", "if", "implements", "import", "instanceof", "int", "interface", "long", "native",
        "new", "package", "private", "protected", "public", "return", "short", "static", "strictfp",
        "super", "switch", "synchronized", "this", "throw", "throws", "transient", "try", "void",
        "volatile", "while", "true", "false", "null", "var", "record", "yield", "sealed", "non-sealed", "permits"
    )

    private val kotlinKeywords = setOf(
        "package", "import", "public", "private", "protected", "internal", "class", "interface", "enum", "object",
        "fun", "val", "var", "if", "else", "for", "while", "do", "when", "is", "in", "break", "continue",
        "return", "this", "super", "override", "open", "abstract", "companion", "data", "sealed",
        "true", "false", "null", "as", "typealias", "constructor", "init", "get", "set"
    )

    private val shKeywords = setOf(
        "if", "then", "else", "elif", "fi", "for", "in", "do", "done", "while", "until", "case", "esac", "function", "select", "time"
    )

    private val jsKeywords = setOf(
        "async", "await", "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete", "do",
        "else", "enum", "export", "extends", "false", "finally", "for", "function", "if", "import", "in", "instanceof",
        "new", "null", "return", "super", "switch", "this", "throw", "true", "try", "typeof", "var", "void", "while",
        "with", "yield", "let", "static", "of", "get", "set"
    )

    fun highlight(text: String, fileName: String, isDark: Boolean): AnnotatedString {
        var lastDot = -1
        for (i in fileName.length - 1 downTo 0) {
            if (fileName[i] == '.') {
                lastDot = i
                break
            }
        }
        val extension = if (lastDot != -1) fileName.substring(lastDot + 1).lowercase() else ""
        return when (extension) {
            "java" -> highlightByKeywords(text, javaKeywords, isDark)
            "kt", "kts" -> highlightByKeywords(text, kotlinKeywords, isDark)
            "sh", "bash" -> highlightByKeywords(text, shKeywords, isDark)
            "js", "ts", "jsx", "tsx" -> highlightByKeywords(text, jsKeywords, isDark)
            "xml", "html", "fxml" -> highlightXml(text, isDark)
            "json" -> highlightJson(text, isDark)
            "properties", "ini" -> highlightProperties(text, isDark)
            "md" -> highlightMarkdown(text, isDark)
            "css", "scss" -> highlightCss(text, isDark)
            else -> AnnotatedString(text)
        }
    }

    private fun highlightByKeywords(text: String, keywords: Set<String>, isDark: Boolean): AnnotatedString {
        val keywordColor = if (isDark) Color(0xFFBD93F9) else Color(0xFF005CC5)
        val stringColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)
        val commentColor = if (isDark) Color(0xFF6272A4) else Color(0xFF6A737D)
        val annotationColor = if (isDark) Color(0xFFFF79C6) else Color(0xFFD73A49)
        val numberColor = if (isDark) Color(0xFF8BE9FD) else Color(0xFF005CC5)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                // Comments
                if (index < len - 1 && text[index] == '/' && text[index + 1] == '/') {
                    val endOfLine = text.indexOf('\n', index)
                    val commentEnd = if (endOfLine == -1) len else endOfLine
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }
                
                // Shell comments
                if (text[index] == '#') {
                    val endOfLine = text.indexOf('\n', index)
                    val commentEnd = if (endOfLine == -1) len else endOfLine
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }

                if (index < len - 1 && text[index] == '/' && text[index + 1] == '*') {
                    val blockEnd = text.indexOf("*/", index)
                    val commentEnd = if (blockEnd == -1) len else blockEnd + 2
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }

                // Strings
                if (text[index] == '"') {
                    val nextQuote = text.indexOf('"', index + 1)
                    val stringEnd = if (nextQuote == -1) len else nextQuote + 1
                    withStyle(SpanStyle(color = stringColor)) {
                        append(text.substring(index, stringEnd))
                    }
                    index = stringEnd
                    continue
                }

                if (text[index] == '\'') {
                    val nextQuote = text.indexOf('\'', index + 1)
                    val charEnd = if (nextQuote == -1) len else nextQuote + 1
                    withStyle(SpanStyle(color = stringColor)) {
                        append(text.substring(index, charEnd))
                    }
                    index = charEnd
                    continue
                }

                // Annotations
                if (text[index] == '@') {
                    var endOfWord = index + 1
                    while (endOfWord < len && text[endOfWord].isLetterOrDigit()) {
                        endOfWord++
                    }
                    withStyle(SpanStyle(color = annotationColor, fontWeight = FontWeight.Bold)) {
                        append(text.substring(index, endOfWord))
                    }
                    index = endOfWord
                    continue
                }

                // Words / Identifiers / Keywords
                if (text[index].isLetter() || text[index] == '_') {
                    var endOfWord = index + 1
                    while (endOfWord < len && (text[endOfWord].isLetterOrDigit() || text[endOfWord] == '_')) {
                        endOfWord++
                    }
                    val word = text.substring(index, endOfWord)
                    if (keywords.contains(word)) {
                        withStyle(SpanStyle(color = keywordColor, fontWeight = FontWeight.Bold)) {
                            append(word)
                        }
                    } else {
                        append(word)
                    }
                    index = endOfWord
                    continue
                }

                // Numbers
                if (text[index].isDigit()) {
                    var endOfNum = index + 1
                    while (endOfNum < len && (text[endOfNum].isLetterOrDigit() || text[endOfNum] == '.')) {
                        endOfNum++
                    }
                    withStyle(SpanStyle(color = numberColor)) {
                        append(text.substring(index, endOfNum))
                    }
                    index = endOfNum
                    continue
                }

                // Default
                append(text[index])
                index++
            }
        }
    }

    private fun highlightXml(text: String, isDark: Boolean): AnnotatedString {
        val tagColor = if (isDark) Color(0xFFFF79C6) else Color(0xFF22863A)
        val attrColor = if (isDark) Color(0xFF50FA7B) else Color(0xFF6F42C1)
        val valueColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)
        val commentColor = if (isDark) Color(0xFF6272A4) else Color(0xFF6A737D)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                // XML comments
                if (index < len - 3 && text.startsWith("<!--", index)) {
                    val blockEnd = text.indexOf("-->", index)
                    val commentEnd = if (blockEnd == -1) len else blockEnd + 3
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }

                // XML tags
                if (text[index] == '<') {
                    val closeAngle = text.indexOf('>', index)
                    val tagEnd = if (closeAngle == -1) len else closeAngle + 1
                    val tagContent = text.substring(index, tagEnd)

                    // Color tag contents
                    var tagIndex = 0
                    val tagLen = tagContent.length
                    while (tagIndex < tagLen) {
                        if (tagContent[tagIndex] == '<' || tagContent[tagIndex] == '>' || tagContent[tagIndex] == '/') {
                            withStyle(SpanStyle(color = tagColor)) {
                                append(tagContent[tagIndex].toString())
                            }
                            tagIndex++
                        } else if (tagContent[tagIndex] == '"') {
                            val nextQuote = tagContent.indexOf('"', tagIndex + 1)
                            val valEnd = if (nextQuote == -1) tagLen else nextQuote + 1
                            withStyle(SpanStyle(color = valueColor)) {
                                append(tagContent.substring(tagIndex, valEnd))
                            }
                            tagIndex = valEnd
                        } else if (tagContent[tagIndex].isLetter()) {
                            var wordEnd = tagIndex + 1
                            while (wordEnd < tagLen && (tagContent[wordEnd].isLetterOrDigit() || tagContent[wordEnd] == '-' || tagContent[wordEnd] == ':')) {
                                wordEnd++
                            }
                            val word = tagContent.substring(tagIndex, wordEnd)
                            val eqIdx = tagContent.indexOf('=', wordEnd)
                            val isAttrName = eqIdx != -1 && eqIdx - wordEnd < 3
                            if (isAttrName) {
                                withStyle(SpanStyle(color = attrColor)) {
                                    append(word)
                                }
                            } else {
                                withStyle(SpanStyle(color = tagColor, fontWeight = FontWeight.Bold)) {
                                    append(word)
                                }
                            }
                            tagIndex = wordEnd
                        } else {
                            append(tagContent[tagIndex].toString())
                            tagIndex++
                        }
                    }
                    index = tagEnd
                    continue
                }

                append(text[index])
                index++
            }
        }
    }

    private fun highlightJson(text: String, isDark: Boolean): AnnotatedString {
        val keyColor = if (isDark) Color(0xFFFF79C6) else Color(0xFF6F42C1)
        val valueColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)
        val numberColor = if (isDark) Color(0xFF8BE9FD) else Color(0xFF005CC5)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                if (text[index] == '"') {
                    val nextQuote = text.indexOf('"', index + 1)
                    val strEnd = if (nextQuote == -1) len else nextQuote + 1
                    val word = text.substring(index, strEnd)
                    val colonIndex = text.indexOf(':', strEnd)
                    val isKey = colonIndex != -1 && text.substring(strEnd, colonIndex).trim().isEmpty()
                    if (isKey) {
                        withStyle(SpanStyle(color = keyColor, fontWeight = FontWeight.Bold)) {
                            append(word)
                        }
                    } else {
                        withStyle(SpanStyle(color = valueColor)) {
                            append(word)
                        }
                    }
                    index = strEnd
                    continue
                }

                if (text[index].isDigit()) {
                    var endOfNum = index + 1
                    while (endOfNum < len && (text[endOfNum].isDigit() || text[endOfNum] == '.')) {
                        endOfNum++
                    }
                    withStyle(SpanStyle(color = numberColor)) {
                        append(text.substring(index, endOfNum))
                    }
                    index = endOfNum
                    continue
                }

                append(text[index])
                index++
            }
        }
    }

    private fun highlightProperties(text: String, isDark: Boolean): AnnotatedString {
        val keyColor = if (isDark) Color(0xFFBD93F9) else Color(0xFF005CC5)
        val valColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)
        val commentColor = if (isDark) Color(0xFF6272A4) else Color(0xFF6A737D)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                if (text[index] == '#' || text[index] == '!') {
                    val endOfLine = text.indexOf('\n', index)
                    val commentEnd = if (endOfLine == -1) len else endOfLine
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }

                val eqIndex = text.indexOf('=', index)
                val lineEndIndex = text.indexOf('\n', index)
                val actualLineEnd = if (lineEndIndex == -1) len else lineEndIndex

                if (eqIndex in index..<actualLineEnd) {
                    val key = text.substring(index, eqIndex)
                    withStyle(SpanStyle(color = keyColor, fontWeight = FontWeight.Bold)) {
                        append(key)
                    }
                    append("=")
                    val value = text.substring(eqIndex + 1, actualLineEnd)
                    withStyle(SpanStyle(color = valColor)) {
                        append(value)
                    }
                    index = actualLineEnd
                    continue
                }

                append(text[index])
                index++
            }
        }
    }

    private fun highlightMarkdown(text: String, isDark: Boolean): AnnotatedString {
        val hColor = if (isDark) Color(0xFFFF79C6) else Color(0xFF22863A)
        val codeColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                // Headings
                if (text[index] == '#' && (index == 0 || text[index - 1] == '\n')) {
                    var hCount = 0
                    while (index < len && text[index] == '#') {
                        hCount++
                        index++
                    }
                    val endOfLine = text.indexOf('\n', index)
                    val lineEnd = if (endOfLine == -1) len else endOfLine
                    withStyle(SpanStyle(color = hColor, fontWeight = FontWeight.Bold)) {
                        for (i in 1..hCount) append("#")
                        append(text.substring(index, lineEnd))
                    }
                    index = lineEnd
                    continue
                }

                // Inline code or code block
                if (text[index] == '`') {
                    var backticks = 0
                    while (index < len && text[index] == '`') {
                        backticks++
                        index++
                    }
                    val btStr = buildString { for (i in 1..backticks) append("`") }
                    val nextTicks = text.indexOf(btStr, index)
                    val codeEnd = if (nextTicks == -1) len else nextTicks
                    withStyle(SpanStyle(color = codeColor, fontFamily = FontFamily.Monospace)) {
                        append(btStr)
                        append(text.substring(index, codeEnd))
                        if (nextTicks != -1) {
                            append(btStr)
                        }
                    }
                    index = if (nextTicks == -1) len else nextTicks + backticks
                    continue
                }

                append(text[index])
                index++
            }
        }
    }

    private fun highlightCss(text: String, isDark: Boolean): AnnotatedString {
        val selectorColor = if (isDark) Color(0xFF50FA7B) else Color(0xFF22863A)
        val propertyColor = if (isDark) Color(0xFF8BE9FD) else Color(0xFF005CC5)
        val valueColor = if (isDark) Color(0xFFF1FA8C) else Color(0xFF032F62)
        val commentColor = if (isDark) Color(0xFF6272A4) else Color(0xFF6A737D)

        return buildAnnotatedString {
            var index = 0
            val len = text.length

            while (index < len) {
                // Comments /* ... */
                if (index < len - 1 && text[index] == '/' && text[index + 1] == '*') {
                    val endComment = text.indexOf("*/", index + 2)
                    val commentEnd = if (endComment == -1) len else endComment + 2
                    withStyle(SpanStyle(color = commentColor)) {
                        append(text.substring(index, commentEnd))
                    }
                    index = commentEnd
                    continue
                }

                // Simple CSS parsing logic
                if (text[index].isLetter() || text[index] == '.' || text[index] == '#' || text[index] == '*') {
                    var endOfWord = index + 1
                    while (endOfWord < len && (text[endOfWord].isLetterOrDigit() || text[endOfWord] == '-' || text[endOfWord] == '_' || text[endOfWord] == '.' || text[endOfWord] == '#')) {
                        endOfWord++
                    }
                    val word = text.substring(index, endOfWord)
                    
                    // Check if it's a property (followed by :) or selector (before {)
                    val nextColon = text.indexOf(':', endOfWord)
                    val nextBrace = text.indexOf('{', endOfWord)
                    
                    if (nextColon != -1 && (nextBrace == -1 || nextColon < nextBrace)) {
                        withStyle(SpanStyle(color = propertyColor)) {
                            append(word)
                        }
                    } else {
                        withStyle(SpanStyle(color = selectorColor, fontWeight = FontWeight.Bold)) {
                            append(word)
                        }
                    }
                    index = endOfWord
                    continue
                }

                if (text[index] == ':') {
                    append(":")
                    var endOfVal = text.indexOf(';', index + 1)
                    if (endOfVal == -1) endOfVal = text.indexOf('}', index + 1)
                    if (endOfVal == -1) endOfVal = len
                    
                    withStyle(SpanStyle(color = valueColor)) {
                        append(text.substring(index + 1, endOfVal))
                    }
                    index = endOfVal
                    continue
                }

                append(text[index])
                index++
            }
        }
    }
}
