// Generated from TransitionLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.transition.antlr;
import org.antlr.v4.runtime.tree.ParseTreeVisitor;

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link TransitionLabelParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public interface TransitionLabelVisitor<T> extends ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link TransitionLabelParser#transitionLabel}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTransitionLabel(TransitionLabelParser.TransitionLabelContext ctx);
	/**
	 * Visit a parse tree produced by {@link TransitionLabelParser#eventOrMessage}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitEventOrMessage(TransitionLabelParser.EventOrMessageContext ctx);
	/**
	 * Visit a parse tree produced by {@link TransitionLabelParser#condition}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitCondition(TransitionLabelParser.ConditionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TransitionLabelParser#conditionAction}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitConditionAction(TransitionLabelParser.ConditionActionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TransitionLabelParser#transitionAction}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTransitionAction(TransitionLabelParser.TransitionActionContext ctx);
}