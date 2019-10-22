/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package eightpuzzlev2;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Vector;
/**
 *
 * @author swaraj
 */
public class EightPuzzlev2 {

    /**
     * @param args the command line arguments
     */
    private int count=0;                                                    // Initialize gn ie. no. of moves to 0
    private Board start;
    private Board goal;
    private ArrayList<Board> closed = new ArrayList<>();
    private PriorityQueue<Board> open  = new PriorityQueue<>(new FxComparator());
   
    public void initStart()                                              //Accept and display start board
    {
        System.out.println("\n\n Enter start Board : ");
        start=new Board();
        start.initBoard();
        start.setGx(0);
        System.out.println("\n\nThe given start board is : ");
        start.display();
    }
    
    public void initGoal()                                               //Accept and display goal board
    {
        System.out.println("\n\n Enter goal Board : ");
        goal=new Board();
        goal.initBoard();
        System.out.println("\n\nThe given goal board is : ");
        goal.display();
    }
 
    
    public void solve()                                           // Solve puzzle using A* algorithm
    {
        
        open.add(start);
        
        while(true)
        {
            Board cur = open.poll();
            System.out.println("\n\nBoard after "+count+" moves : ");
            cur.display();
            closed.add(cur);
            if(cur.equals(goal))                                 //Check if goal is achieved nad return
            {
                System.out.println("\nGoal state achieved.");
                return;
            }
            
            count++;
                      
            ArrayList<Board> candidates = cur.nextMove( goal, open, closed);          // get the board after next move
            open.addAll(candidates);
            
        }
    }
    
    public static void main(String[] args) {
        // TODO code application logic here
        
        EightPuzzlev2 ep = new EightPuzzlev2();                      // Instantiate and solve the puzzle
        ep.initStart();
        ep.initGoal();
        
        System.out.println("\n\nThe board is solved as : \n");
        ep.solve();
        
        
        
    }
}
