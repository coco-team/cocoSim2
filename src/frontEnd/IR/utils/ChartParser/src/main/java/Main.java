import edu.uiowa.chart.state.StateAction;
import edu.uiowa.chart.state.StateVisitor;
import edu.uiowa.chart.state.antlr.*;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;

public class Main {

    public static void main(String[] args)
    {
        String stateLabel = "increasing\n" +
                            "entry:\n" +
                            "prePopulation = population;\n" +
                            "population = prePopulation * 2.0;";
        CharStream charStream = CharStreams.fromString(stateLabel);
        StateLabelLexer lexer = new StateLabelLexer(charStream);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        StateLabelParser parser = new StateLabelParser(tokenStream);

        ParseTree tree =  parser.stateLabel();
        System.out.println(tree.toStringTree(parser));
        StateVisitor visitor = new StateVisitor();
        StateAction stateAction =  visitor.visit(tree);
        System.out.println(stateAction);
    }
}
