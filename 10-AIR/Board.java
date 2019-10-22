/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package eightpuzzlev2;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.PriorityQueue;
import java.util.Scanner;
import javax.swing.JOptionPane;


                                                                                    //board class for eight puzzle matrix
public class Board {
    
    private String board[][];
    private  int blankX,blankY;                                                     // co-ordinates for blank tile
    private int fx,gx;
    
    public Board()
    {
        this.board = new String[3][3];       
    }
    
    public Board(Board b)                                                           //constructor to initialise Board
    {
        this.board = b.board;
        this.blankX = b.blankX;
        this.blankY = b.blankY;
    }
    
    public int getFx()
    {
        return fx;
    }
    
    public void setFx(int fx)
    {
        this.fx = fx;
    }
    
    public int getGx()
    {
        return gx;
    }
    
    public void setGx(int gx)
    {
        this.gx = gx;
    }
    
    public void initBoard()                                                         //initialize the board
    {
        Scanner inp = new Scanner(System.in);
        System.out.println("\nEnter one tile as '-' ie. Blank tile\n");
        for(int i=0; i<3; i++)
        {
            for(int j=0; j<3; j++)
            {
                board[i][j] = JOptionPane.showInputDialog("Enter the value of tile ["+i+"]["+(j)+"] : ");
                
                if(board[i][j].equals("-"))                                         //store the location of blank symbol
                {
                    blankX=i;
                    blankY=j;
                }
            }
        }
    }
            
    public String[][] getBoard()
    {
        return board;
    }

    public void setBoard(String[][] board)                                          // Set the board puzzle matrix                                  
    {
        for(int i=0; i<3; i++)
        {
            for(int j=0; j<3; j++)
            {
                this.board[i][j] = board[i][j];
            }
        }
    }
    
    
    
    public int getBlankX()
    {
        return blankX;
    }
    
     public int getBlankY()
    {
        return blankY;
    }
     
     public void setBlankX(int x)
    {
        blankX = x;
    }
    
     public void setBlankY(int y)
    {
        blankY = y;
    }
    
    public void display()
    {
        for(int i=0; i<3; i++)
        {
            for(int j=0; j<3; j++)
            {
                System.out.print("\t"+board[i][j]);
            }
            System.out.println();
        }
    }
    
    public ArrayList<Board> nextMove(Board goal, PriorityQueue<Board> open, ArrayList<Board> closed)    //method to check possible moves and select optimum 
    {
        Board temp = new Board();
        Board next;
        int minFn = 999;
        int gn = getGx() + 1;
        ArrayList<Board> candidates = new ArrayList<>();
        System.out.println("\nPossible moves are : ");
        if(blankY>0)                                                      // Condition for possible left move
        {
            temp.setBoard(board);
            temp.swap(blankX, blankY, blankX, blankY-1);                  // Swap blank tile
            
            if(!inOpen(open, temp) && !inClosed(closed, temp))                                                // Check for minimum fn and set the next board accordingly
            {
                int fn =  (temp.getHn(goal)+gn);                              // Calculate fn = hn + gn
                System.out.println("\nFor Fn = "+fn+" : ");
                temp.display();
                minFn = fn;
                next = new Board();
                next.setBoard(temp.board);
                next.setBlankX(blankX);                             
                next.setBlankY(blankY-1);
                next.setGx(gn);
                next.setFx(fn);
                candidates.add(next);
            }
            
        }
        if(blankY<2)                                                      // Condition for possible right move         
        {
            temp.setBoard(board);
            temp.swap(blankX, blankY, blankX, blankY+1);
            
            if(!inOpen(open, temp) && !inClosed(closed, temp))
            {
                int fn =  (temp.getHn(goal)+gn);                              // Calculate fn = hn + gn
                System.out.println("\nFor Fn = "+fn+" : ");
                temp.display();
                minFn = fn;
                next = new Board();
                next.setBoard(temp.board);
                next.setBlankX(blankX);
                next.setBlankY(blankY+1);
                next.setGx(gn);
                next.setFx(fn);
                candidates.add(next);
            }
            
        }
        if(blankX>0)                                                      // Condition for possible up move
        {
            temp.setBoard(board);
            temp.swap(blankX, blankY, blankX-1, blankY);
            
            if(!inOpen(open, temp) && !inClosed(closed, temp))
            {
                int fn =  (temp.getHn(goal)+gn);
                System.out.println("\nFor Fn = "+fn+" : ");
                temp.display();
                minFn = fn;
                next = new Board();
                next.setBoard(temp.board);
                next.setBlankX(blankX-1);
                next.setBlankY(blankY);
                next.setGx(gn);
                next.setFx(fn);
                candidates.add(next);
            }
            
        }
        if(blankX<2)                                                      // Condition for possible down move
        {
            temp.setBoard(board);
            temp.swap(blankX, blankY, blankX+1, blankY);
            
            if(!inOpen(open, temp) && !inClosed(closed, temp))
            {
                int fn =  (temp.getHn(goal)+gn);
                System.out.println("\nFor Fn = "+fn+" : ");
                temp.display();
                minFn = fn;
                next = new Board();
                next.setBoard(temp.board);
                next.setBlankX(blankX+1);
                next.setBlankY(blankY);
                next.setGx(gn);
                next.setFx(fn);
                candidates.add(next);
            }
            
        }
        /*
        Iterator itr = candidates.iterator();
        while(itr.hasNext())
        {
            Board temp1 = (Board) itr.next();
           
            temp1.display();
        }*/
        return candidates;                                                      // return board with min fn
    }
    
   
    public void swap(int i1, int j1, int i2, int j2)                      // Swap tile values
    {
        String temp = board[i1][j1];
        board[i1][j1] = board[i2][j2];
        board[i2][j2] = temp;
        
    }
   
    public boolean equals(Board b)                                        // check for board equality
    {
        for(int i=0; i<3; i++)
        {
            for(int j=0; j<3; j++)
            {
                if(!this.board[i][j].equals(b.board[i][j]) )
                {
                    return false;
                }
            }
            
        }
        return true;
            
    }
    
    public int getHn(Board goal)                                          // get hn by Hamming method
    {
        int hn = 0;
        for(int i=0; i<3; i++)
        {
            for(int j=0; j<3; j++)
            {
                if(!this.board[i][j].equals(goal.board[i][j]))
                {
                    hn++;
                }
            }
            
        }
        return hn;
    }
    
    public boolean inClosed(ArrayList<Board> closed, Board temp)
    {
        Iterator itr = closed.iterator();
        while(itr.hasNext())
        {
            Board temp1 = (Board) itr.next();
           
            if(temp.equals(temp1))
                return true;
        }
        return false;
    }
    
    public boolean inOpen(PriorityQueue<Board> open, Board temp)
    {
        Iterator itr = open.iterator();
        while(itr.hasNext())
        {
            Board temp1 = (Board) itr.next();
           
            if(temp.equals(temp1))
                return true;
        }
        return false;
    }
}
