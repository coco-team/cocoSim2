// Generated from StateLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.state.antlr;
import org.antlr.v4.runtime.tree.ParseTreeVisitor;

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link StateLabelParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public interface StateLabelVisitor<T> extends ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link StateLabelParser#stateLabel}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitStateLabel(StateLabelParser.StateLabelContext ctx);
	/**
	 * Visit a parse tree produced by {@link StateLabelParser#actions}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitActions(StateLabelParser.ActionsContext ctx);
	/**
	 * Visit a parse tree produced by {@link StateLabelParser#action}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitAction(StateLabelParser.ActionContext ctx);
	/**
	 * Visit a parse tree produced by {@link StateLabelParser#actionType}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitActionType(StateLabelParser.ActionTypeContext ctx);
	/**
	 * Visit a parse tree produced by {@link StateLabelParser#actionBody}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitActionBody(StateLabelParser.ActionBodyContext ctx);
}