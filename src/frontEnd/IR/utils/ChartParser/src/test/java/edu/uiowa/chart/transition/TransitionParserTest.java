package edu.uiowa.chart.transition;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class TransitionParserTest {

    @Test
    void parseCondition()
    {
        String transitionLabel = "[x<0]";
        Transition transition = TransitionParser.parse(transitionLabel);
        assertEquals("x<0", transition.condition);
    }

    @Test
    void parseConditionBoolean()
    {
        String transitionLabel = "[p]";
        Transition transition = TransitionParser.parse(transitionLabel);
        assertEquals("p", transition.condition);
    }

    @Test
    void parseConditionAction1()
    {
        String transitionLabel = "[x<0] {x =1;}";
        Transition transition = TransitionParser.parse(transitionLabel);
        assertEquals("x<0", transition.condition);
        assertEquals("x=1;", transition.conditionAction);
    }

    @Test
    void parseConditionAction2()
    {
        String transitionLabel = "[x<0] {x =1; y = 2;}";
        Transition transition = TransitionParser.parse(transitionLabel);
        assertEquals("x<0", transition.condition);
        assertEquals("x=1;y=2;", transition.conditionAction);
    }

    @Test
    void parseConditionActionTransitionAction()
    {
        String transitionLabel = "[x<0] {x =1; y = 2;}/{z=1;}";
        Transition transition = TransitionParser.parse(transitionLabel);
        assertEquals("x<0", transition.condition);
        assertEquals("x=1;y=2;", transition.conditionAction);
        assertEquals("z=1;", transition.transitionAction);
    }
}