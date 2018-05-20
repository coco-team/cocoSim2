package edu.uiowa.chart.state;

class OnAction
{
    // matlab accepts double for n
    public double n;
    public String eventName="";
    public String actions = "";

    public OnAction(double n, String eventName, String actions)
    {
        this.n = n;
        this.eventName = eventName;
        this.actions = actions;
    }
}

public class StateAction
{
    public String [] entry = new String[0];
    public String [] during = new String[0];
    public String [] exit = new String[0];
    public String [] bind = new String[0];
    public OnAction [] on = new OnAction[0];
    public OnAction [] onAfter = new OnAction[0];
    public OnAction [] onBefore = new OnAction[0];
    public OnAction [] onAt = new OnAction[0];
    public OnAction [] onEvery = new OnAction[0];
}