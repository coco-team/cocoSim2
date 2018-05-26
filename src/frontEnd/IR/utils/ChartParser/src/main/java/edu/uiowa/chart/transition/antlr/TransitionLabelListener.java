// Generated from TransitionLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.transition.antlr;
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link TransitionLabelParser}.
 */
public interface TransitionLabelListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link TransitionLabelParser#transitionLabel}.
	 * @param ctx the parse tree
	 */
	void enterTransitionLabel(TransitionLabelParser.TransitionLabelContext ctx);
	/**
	 * Exit a parse tree produced by {@link TransitionLabelParser#transitionLabel}.
	 * @param ctx the parse tree
	 */
	void exitTransitionLabel(TransitionLabelParser.TransitionLabelContext ctx);
	/**
	 * Enter a parse tree produced by {@link TransitionLabelParser#eventOrMessage}.
	 * @param ctx the parse tree
	 */
	void enterEventOrMessage(TransitionLabelParser.EventOrMessageContext ctx);
	/**
	 * Exit a parse tree produced by {@link TransitionLabelParser#eventOrMessage}.
	 * @param ctx the parse tree
	 */
	void exitEventOrMessage(TransitionLabelParser.EventOrMessageContext ctx);
	/**
	 * Enter a parse tree produced by {@link TransitionLabelParser#condition}.
	 * @param ctx the parse tree
	 */
	void enterCondition(TransitionLabelParser.ConditionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TransitionLabelParser#condition}.
	 * @param ctx the parse tree
	 */
	void exitCondition(TransitionLabelParser.ConditionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TransitionLabelParser#conditionAction}.
	 * @param ctx the parse tree
	 */
	void enterConditionAction(TransitionLabelParser.ConditionActionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TransitionLabelParser#conditionAction}.
	 * @param ctx the parse tree
	 */
	void exitConditionAction(TransitionLabelParser.ConditionActionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TransitionLabelParser#transitionAction}.
	 * @param ctx the parse tree
	 */
	void enterTransitionAction(TransitionLabelParser.TransitionActionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TransitionLabelParser#transitionAction}.
	 * @param ctx the parse tree
	 */
	void exitTransitionAction(TransitionLabelParser.TransitionActionContext ctx);
}