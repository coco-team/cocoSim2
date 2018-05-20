package edu.uiowa.chart.state;
import edu.uiowa.chart.state.antlr.*;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;
import java.util.ArrayList;
import java.util.List;


public class StateVisitor extends StateLabelBaseVisitor<StateAction>
{
    private StateAction stateAction = new StateAction();

    private List<String> entry  = new ArrayList<>();
    private List<String> during = new ArrayList<>();
    private List<String> exit   = new ArrayList<>();
    private List<String> bind   = new ArrayList<>();
    private List<OnAction> on       = new ArrayList<>();
    private List<OnAction> onAfter  = new ArrayList<>();
    private List<OnAction> onBefore = new ArrayList<>();
    private List<OnAction> onAt     = new ArrayList<>();
    private List<OnAction> onEvery  = new ArrayList<>();

    @Override
    public StateAction visitStateLabel(StateLabelParser.StateLabelContext ctx)
    {
        super.visitStateLabel(ctx);

        // Matlab doesn't recognize lists. So we need to convert lists to arrays
        stateAction.entry = this.entry.toArray(new String[0]);
        stateAction.during = this.during.toArray(new String[0]);
        stateAction.exit = this.exit.toArray(new String[0]);
        stateAction.bind = this.bind.toArray(new String[0]);
        stateAction.on = this.on.toArray(new OnAction[0]);
        stateAction.onAfter = this.onAfter.toArray(new OnAction[0]);
        stateAction.onBefore = this.onBefore.toArray(new OnAction[0]);
        stateAction.onAt = this.onAt.toArray(new OnAction[0]);
        stateAction.onEvery = this.onEvery.toArray(new OnAction[0]);

        return this.stateAction;
    }

    @Override
    public StateAction visitAction(StateLabelParser.ActionContext ctx)
    {
        if(ctx.children.size() > 0)
        {
            for (StateLabelParser.ActionTypeContext actionType : ctx.actionType())
            {
                addAction(actionType, ctx.actionBody().getText());
            }
        }
        return stateAction;
    }


    private void addAction(StateLabelParser.ActionTypeContext ctx, String actions)
    {
        if ( ctx.getChildCount() > 0 )
        {
            ParseTree firstChild = ctx.getChild(0);

            if (firstChild instanceof TerminalNode)
            {
                Token firstToken = ((TerminalNode) firstChild).getSymbol();
                switch (firstToken.getType())
                {
                    case StateLabelLexer.Entry: {this.entry.add(actions);} break;

                    case StateLabelLexer.During: {this.during.add(actions);} break;

                    case StateLabelLexer.Exit: {this.exit.add(actions);} break;

                    case StateLabelLexer.Bind: {this.bind.add(actions);} break;

                    case StateLabelLexer.On:
                    {
                        if ( ctx.getChildCount() > 1 )
                        {
                            ParseTree secondChild = ctx.getChild(1);
                            if (firstChild instanceof TerminalNode)
                            {
                                Token secondToken = ((TerminalNode) secondChild).getSymbol();
                                switch (secondToken.getType())
                                {
                                    case StateLabelLexer.Identifier:
                                    {
                                            this.on.add(new OnAction(0, secondToken.getText(), actions));
                                    } break;

                                    case StateLabelLexer.After:
                                    {
                                        this.onAfter.add(getOnAction(ctx, actions));
                                    } break;
                                    case StateLabelLexer.Before:
                                    {
                                        this.onBefore.add(getOnAction(ctx, actions));
                                    } break;
                                    case StateLabelLexer.At:
                                    {
                                        this.onAt.add(getOnAction(ctx, actions));
                                    } break;

                                    case StateLabelLexer.Every:
                                    {
                                        this.onEvery.add(getOnAction(ctx, actions));
                                    } break;
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                System.out.println("Expected action type here: " + ctx.getText());
            }
        }
    }

    private OnAction getOnAction(StateLabelParser.ActionTypeContext ctx,String actions)
    {
        // the index of n is 3
        double n = Double.parseDouble(ctx.getChild(3).getText());

        // the index of eventName is 5
        String eventName = ctx.getChild(5).getText();

        return new OnAction(n, eventName, actions);
    }
}
