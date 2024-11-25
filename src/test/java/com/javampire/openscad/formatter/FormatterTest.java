package com.javampire.openscad.formatter;

import com.intellij.application.options.CodeStyle;
import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.command.CommandProcessor;
import com.intellij.psi.codeStyle.CodeStyleManager;
import com.intellij.testFramework.fixtures.LightJavaCodeInsightFixtureTestCase;
import org.junit.Test;

import java.util.List;

public class FormatterTest extends LightJavaCodeInsightFixtureTestCase {

    @Override
    protected String getTestDataPath() {
        return "src/test/testData/openscad/formatter";
    }

    @Test
    public void testFormatterDefault() {
        myFixture.configureByFile("IndentObjectsElements.scad");
        ApplicationManager.getApplication().runWriteAction(() ->
                CommandProcessor.getInstance().runUndoTransparentAction(() ->
                        CodeStyleManager.getInstance(getProject()).reformatText(
                                myFixture.getFile(),
                                List.of(myFixture.getFile().getTextRange())
                        )
                )
        );
        myFixture.checkResultByFile("IndentObjectsElements_result_default.scad");
    }

    @Test
    public void testFormatterNoIndentObjectsElements() {
        myFixture.configureByFile("IndentObjectsElements.scad");
        ApplicationManager.getApplication().runWriteAction(() ->
                CommandProcessor.getInstance().runUndoTransparentAction(() -> {
                    CodeStyle.getCustomSettings(myFixture.getFile(), OpenSCADCodeStyleSettings.class).INDENT_CASCADING_TRANSFORMATIONS = false;
                    CodeStyleManager.getInstance(myFixture.getProject()).reformatText(
                            myFixture.getFile(),
                            List.of(myFixture.getFile().getTextRange())
                    );
                })
        );
        myFixture.checkResultByFile("IndentObjectsElements_result_noIndentCascadingTransformations.scad");
    }
}
