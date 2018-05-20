package edu.uiowa.chart.transition;
import edu.uiowa.chart.transition.antlr.TransitionLabelBaseVisitor;
import edu.uiowa.chart.transition.antlr.TransitionLabelParser;

public class TransitionVisitor extends TransitionLabelBaseVisitor<Transition>
{
    Transition transition = new Transition();

    @Override
    public Transition visitTransitionLabel(TransitionLabelParser.TransitionLabelContext ctx)
    {
        super.visitTransitionLabel(ctx);
        return this.transition;
    }

    @Override
    public Transition visitEventOrMessage(TransitionLabelParser.EventOrMessageContext ctx)
    {
        this.transition.eventOrMessage = ctx.getText();
        return this.transition;
    }

    @Override
    public Transition visitCondition(TransitionLabelParser.ConditionContext ctx) {
        this.transition.condition = ctx.getText();
        return this.transition;
    }

    @Override
    public Transition visitConditionAction(TransitionLabelParser.ConditionActionContext ctx)
    {
        this.transition.conditionAction = ctx.getText();
        return this.transition;
    }

    @Override
    public Transition visitTransitionAction(TransitionLabelParser.TransitionActionContext ctx)
    {
        this.transition.transitionAction = ctx.getText();
        return this.transition;
    }
}
