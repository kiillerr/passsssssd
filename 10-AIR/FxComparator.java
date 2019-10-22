/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package eightpuzzlev2;

import java.util.Comparator;

public class FxComparator implements Comparator<Board>               // Comparator for priority queue based on fx value
{

    @Override
    public int compare(Board o1, Board o2) {
        if(o1.getFx()> o2.getFx())
            return 1;
        else if(o1.getFx() < o2.getFx())
            return -1;
        return 0;
    }
    
}
