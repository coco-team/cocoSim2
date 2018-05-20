package edu.uiowa.chart.transition;

import edu.uiowa.chart.transition.antlr.TransitionLabelLexer;
import edu.uiowa.chart.transition.antlr.TransitionLabelParser;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;


public class TransitionParser
{
    public static Transition parse(String TransitionLabel)
    {
        CharStream charStream = CharStreams.fromString(TransitionLabel);
        TransitionLabelLexer lexer = new TransitionLabelLexer(charStream);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        TransitionLabelParser parser = new TransitionLabelParser(tokenStream);

        ParseTree tree =  parser.transitionLabel();
        TransitionVisitor visitor = new TransitionVisitor();
        Transition transition =  visitor.visit(tree);

        return transition;
    }
}
