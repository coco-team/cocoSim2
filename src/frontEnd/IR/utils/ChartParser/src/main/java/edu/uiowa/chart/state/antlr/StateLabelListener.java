// Generated from StateLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.state.antlr;
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link StateLabelParser}.
 */
public interface StateLabelListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link StateLabelParser#stateLabel}.
	 * @param ctx the parse tree
	 */
	void enterStateLabel(StateLabelParser.StateLabelContext ctx);
	/**
	 * Exit a parse tree produced by {@link StateLabelParser#stateLabel}.
	 * @param ctx the parse tree
	 */
	void exitStateLabel(StateLabelParser.StateLabelContext ctx);
	/**
	 * Enter a parse tree produced by {@link StateLabelParser#actions}.
	 * @param ctx the parse tree
	 */
	void enterActions(StateLabelParser.ActionsContext ctx);
	/**
	 * Exit a parse tree produced by {@link StateLabelParser#actions}.
	 * @param ctx the parse tree
	 */
	void exitActions(StateLabelParser.ActionsContext ctx);
	/**
	 * Enter a parse tree produced by {@link StateLabelParser#action}.
	 * @param ctx the parse tree
	 */
	void enterAction(StateLabelParser.ActionContext ctx);
	/**
	 * Exit a parse tree produced by {@link StateLabelParser#action}.
	 * @param ctx the parse tree
	 */
	void exitAction(StateLabelParser.ActionContext ctx);
	/**
	 * Enter a parse tree produced by {@link StateLabelParser#actionType}.
	 * @param ctx the parse tree
	 */
	void enterActionType(StateLabelParser.ActionTypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link StateLabelParser#actionType}.
	 * @param ctx the parse tree
	 */
	void exitActionType(StateLabelParser.ActionTypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link StateLabelParser#actionBody}.
	 * @param ctx the parse tree
	 */
	void enterActionBody(StateLabelParser.ActionBodyContext ctx);
	/**
	 * Exit a parse tree produced by {@link StateLabelParser#actionBody}.
	 * @param ctx the parse tree
	 */
	void exitActionBody(StateLabelParser.ActionBodyContext ctx);
}