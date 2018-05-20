package edu.uiowa.chart.state;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;


class StateActionParserTest {

    @Test
    void parseState()
    {
        String stateLabel = "increasing";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(0, stateAction.entry.length);
        assertEquals(0, stateAction.during.length);
        assertEquals(0, stateAction.exit.length);
        assertEquals(0, stateAction.bind.length);
        assertEquals(0, stateAction.on.length);
        assertEquals(0, stateAction.onAfter.length);
        assertEquals(0, stateAction.onBefore.length);
        assertEquals(0, stateAction.onAt.length);
        assertEquals(0, stateAction.onEvery.length);
    }


    @Test
    void parseEntry()
    {
        String stateLabel = "increasing\n" +
                "entry: x=y;y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y;y=x*2.0;", stateAction.entry[0]);
    }

    @Test
    void parseEn()
    {
        String stateLabel = "increasing\n" +
                "en: x=y;\ny=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y;\ny=x*2.0;", stateAction.entry[0]);
    }

    @Test
    void parseDuring()
    {
        String stateLabel = "increasing\n" +
                "during: x=y;y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y;y=x*2.0;", stateAction.during[0]);
    }

    @Test
    void parseDu()
    {
        String stateLabel = "increasing\n" +
                "du: x=y,y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y,y=x*2.0;", stateAction.during[0]);
    }

    @Test
    void parseExit()
    {
        String stateLabel = "increasing\n" +
                "exit: x=y,y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y,y=x*2.0;", stateAction.exit[0]);
    }

    @Test
    void parseEx()
    {
        String stateLabel = "increasing\n" +
                "ex: x=y,y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y,y=x*2.0;", stateAction.exit[0]);
    }

    @Test
    void parseEntryDuring()
    {
        String stateLabel = "increasing\n" +
                "entry, during: x=y,y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y,y=x*2.0;", stateAction.entry[0]);
        assertEquals("x=y,y=x*2.0;", stateAction.during[0]);
    }

    @Test
    void parseEntryDuringExit()
    {
        String stateLabel = "increasing\n" +
                "entry, during, exit: x=y,y=x*2.0;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=y,y=x*2.0;", stateAction.entry[0]);
        assertEquals("x=y,y=x*2.0;", stateAction.during[0]);
        assertEquals("x=y,y=x*2.0;", stateAction.exit[0]);
    }

    @Test
    void parseEntryActionDuringAction()
    {
        String stateLabel = "increasing\n" +
                "entry: x=x;\n" +
                "during: y=y;" ;

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=x;\n", stateAction.entry[0]);
        assertEquals("y=y;", stateAction.during[0]);
    }

    @Test
    void parseEntryExitActionExAction()
    {
        String stateLabel = "increasing\n" +
                "entry, exit: x=x;\n" +
                "ex: y=y;" ;

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=x;\n", stateAction.entry[0]);
        assertEquals("x=x;\n", stateAction.exit[0]);
        assertEquals("y=y;", stateAction.exit[1]);
    }

    @Test
    void parseEnExActionDuExAction()
    {
        String stateLabel = "increasing\n" +
                "en, ex: x=x;\n" +
                "du, ex: y=y;" ;

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("x=x;\n", stateAction.entry[0]);
        assertEquals("y=y;", stateAction.during[0]);
        assertEquals("x=x;\n", stateAction.exit[0]);
        assertEquals("y=y;", stateAction.exit[1]);
    }

    @Test
    void parseBindEventName()
    {
        String stateLabel = "increasing\n" +
                "bind: name";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("name", stateAction.bind[0]);
    }

    @Test
    void parseBindEventNames()
    {
        String stateLabel = "increasing\n" +
                "bind: name1, name2; name3\n name4";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals("name1,name2;name3\nname4", stateAction.bind[0]);
    }

    @Test
    void parseOn()
    {
        String stateLabel = "increasing\n" +
                "on name: x=x;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(0, stateAction.on[0].n);
        assertEquals("name", stateAction.on[0].eventName);
        assertEquals("x=x;", stateAction.on[0].actions);
    }

    @Test
    void parseAfter()
    {
        String stateLabel = "increasing\n" +
                "on after(5, name): x=x;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(5, stateAction.onAfter[0].n);
        assertEquals("name", stateAction.onAfter[0].eventName);
        assertEquals("x=x;", stateAction.onAfter[0].actions);
    }

    @Test
    void parseBefore()
    {
        String stateLabel = "increasing\n" +
                "on before(5, name): x=x;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(5, stateAction.onBefore[0].n);
        assertEquals("name", stateAction.onBefore[0].eventName);
        assertEquals("x=x;", stateAction.onBefore[0].actions);
    }

    @Test
    void parseAt()
    {
        String stateLabel = "increasing\n" +
                "on at(5, name): x=x;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(5, stateAction.onAt[0].n);
        assertEquals("name", stateAction.onAt[0].eventName);
        assertEquals("x=x;", stateAction.onAt[0].actions);
    }

    @Test
    void parseEvery()
    {
        String stateLabel = "increasing\n" +
                "on every(5, name): x=x;";

        StateAction stateAction = StateParser.parse(stateLabel);
        assertEquals(5, stateAction.onEvery[0].n);
        assertEquals("name", stateAction.onEvery[0].eventName);
        assertEquals("x=x;", stateAction.onEvery[0].actions);
    }
    @Test
    void parseOnAfterBeforeAtEvery()
    {
        String stateLabel = "increasing\n" +
                "entry: x=x;\n" +
                "during: x=x;\n" +
                "exit: x=x;\n" +
                "bind:name;\n" +
                "on name: x=x;\n" +
                "on after(5, name): x=x;\n" +
                "on before(5, name): x=x;\n" +
                "on at(5, name): x=x;\n" +
                "on every(5, name): x=x;\n" ;


        StateAction stateAction = StateParser.parse(stateLabel);


        assertEquals("x=x;\n", stateAction.entry[0]);
        assertEquals("x=x;\n", stateAction.during[0]);
        assertEquals("x=x;\n", stateAction.exit[0]);
        assertEquals("name;\n", stateAction.bind[0]);

        assertEquals(0, stateAction.on[0].n);
        assertEquals("name", stateAction.on[0].eventName);
        assertEquals("x=x;\n", stateAction.onEvery[0].actions);
        assertEquals(5, stateAction.onAfter[0].n);
        assertEquals("name", stateAction.onAfter[0].eventName);
        assertEquals("x=x;\n", stateAction.onAfter[0].actions);
        assertEquals(5, stateAction.onBefore[0].n);
        assertEquals("name", stateAction.onBefore[0].eventName);
        assertEquals("x=x;\n", stateAction.onBefore[0].actions);
        assertEquals(5, stateAction.onAt[0].n);
        assertEquals("name", stateAction.onAt[0].eventName);
        assertEquals("x=x;\n", stateAction.onAt[0].actions);
        assertEquals(5, stateAction.onEvery[0].n);
        assertEquals("name", stateAction.onEvery[0].eventName);
        assertEquals("x=x;\n", stateAction.onEvery[0].actions);
    }
}