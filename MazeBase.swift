//
//  MazeBase.swift
//  Jundo
//
//  Created by TA on 05/05/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import SpriteKit

class Visited {
    
    private enum status: Int { case none, partial, complete }
    
    private let rows: Int
    private let cols: Int
    private var array: [status]
    
    init(rows: Int, cols: Int){
        self.rows = rows
        self.cols = cols
        array = Array(repeating: .none, count: rows*cols)
    }
    
    func reset() {
        array = array.map { _ in .none }
    }
    
    func visit(_ cell: MazeCell) {
        set(cell, .complete)
    }
    
    func partial(_ cell: MazeCell) {
        set(cell, .partial)
    }
    
    func unvisit(_ cell: MazeCell) {
        set(cell, .none)
    }
    
    func isUnvisited(_ cell: MazeCell) -> Bool {
        return isEqual(cell, .none)
    }
    
    func isVisited(_ cell: MazeCell) -> Bool {
        return isEqual(cell, .complete)
    }
    
    private func index(_ row: Int, _ col: Int) -> Int {
        return row*cols+col
    }
    
    private func set(_ cell: MazeCell, _ status: status) {
        array[index(cell.row, cell.col)] = status
    }
    
    private func isEqual(_ cell: MazeCell, _ status: status) -> Bool {
        return array[index(cell.row, cell.col)] == status
    }
    
}

class MinHeap {
  
    let columns: Int
    var indices: [Int]
    var heap: [MazeCell]
    var isEmpty: Bool { return heap.count == 0 }
    var lastIndex: Int { return heap.count - 1 }
    
    init(rows: Int, cols: Int) {
        heap = []
        columns = cols
        indices = Array<Int>(repeating: -1, count: rows*cols)
    }
    
    func index(_ cell: MazeCell) -> Int {
        return cell.row*columns + cell.col
    }
    
    func index(of cell: MazeCell, set i: Int) {
        indices[index(cell)] = i
    }
    
    func index(of cell: MazeCell) -> Int {
        return indices[index(cell)]
    }
    
    func insert(_ cell: MazeCell) {
        var i = index(of: cell)
        if i < 0 {
            heap.append(cell)
            i = lastIndex
            index(of: cell, set: i)
        }
        heapifyUp(i)
    }
    
    func remove() -> MazeCell {
        swap(0, lastIndex)
        let cell = heap.removeLast()
        heapifyDown()
        return cell
    }
    
    func heapifyUp(_ childIndex: Int) {
        var ci = childIndex
        while let pi = parent(ci), isLessThan(ci, pi) {
            swap(ci, pi)
            ci = pi
        }
    }
    
    func heapifyDown(_ parentIndex: Int = 0) {
        var pi = parentIndex
        while let ci = child(pi), isLessThan(ci, pi) {
            swap(pi, ci)
            pi = ci
        }
    }
    
    func parent(_ index: Int) -> Int? {
        let i = (index-1) / 2
        return index != 0 && inBounds(i) ? i : nil
    }
    
    func child(_ index: Int) -> Int? {
        let li = (index<<1) + 1
        let ri = (index<<1) + 2
        if inBounds(li) {
            return inBounds(ri) ? (isLessThan(li, ri) ? li : ri) : li
        }
        return inBounds(ri) ? ri : nil
    }
    
    func inBounds(_ index: Int) -> Bool {
        return index >= 0 && index < heap.count
    }
    
    func isLessThan(_ i: Int, _ j: Int) -> Bool {
        return heap[i].distance < heap[j].distance
    }
    
    func swap(_ i: Int, _ j: Int) {
        if i != j {
            var a = heap[i], b = heap[j]
            Swift.swap(&a, &b)
            Swift.swap(&indices[index(a)], &indices[index(b)])
        }
    }
    
};

class MazeCell {
    
    var row: Int
    var col: Int
    var paths: Int
    var isPathCell: Bool
    var position: CGPoint
    var distance: Int
    var predecessor: MazeCell?

    var up: Bool { return (paths & directions.up.rawValue) != 0 }
    var down: Bool { return (paths & directions.down.rawValue) != 0 }
    var left: Bool { return (paths & directions.left.rawValue) != 0 }
    var right: Bool { return (paths & directions.right.rawValue) != 0 }
    
    init(row: Int, col: Int, pos: CGPoint = CGPoint.zero) {
        self.row = row
        self.col = col
        position = pos
        isPathCell = false
        distance = Int.max
        paths = 0
    }
    
    static func == (left: MazeCell, right: MazeCell) -> Bool {
        return (left.row == right.row) && (left.col == right.col)
    }
    
    static func != (left: MazeCell, right: MazeCell) -> Bool {
        return !(left == right)
    }
    
}

class MazeBase {
    
    enum MazeError: Error { case failed }
    
    private let rows: Int
    private let cols: Int
    private var position: MazeCell
    private let canvas: SKSpriteNode
    private var maze: [MazeCell]
    private let cellSize: CGFloat
    private let cellBorder: CGFloat
    private let cellZeroZeroCentre: CGPoint
    var source: MazeCell!
    var destination: MazeCell!
    var step: CGFloat { return cellSize }
    var width: CGFloat { return CGFloat(cols) * cellSize }
    var height: CGFloat { return CGFloat(rows) * cellSize }
    
    init(rows: Int, cols: Int, canvas: SKSpriteNode) throws {
        
        if rows < 2 || cols < 2 {
            throw MazeError.failed
        }
        
        self.maze = []
        self.rows = rows
        self.cols = cols
        self.canvas = canvas
        self.cellBorder = CGFloat(10.0)
        self.position = MazeCell(row: 0, col: 0)
        
        let roundTo = CGFloat(2.0)
        let cgRows = CGFloat(rows)
        let cgCols = CGFloat(cols)
        let width = canvas.size.width
        let height = canvas.size.height
        let size = min(width/cgCols, height/cgRows)
        cellSize = floor(size/roundTo)*roundTo
        let offset = cellSize*0.5
        cellZeroZeroCentre = CGPoint(x: (cgCols * -offset) + offset, y: (cgRows * offset) - offset)

        for row in 0..<rows {
            for col in 0..<cols {
                let position = translate(row: row, col: col)
                maze.append(MazeCell(row: row, col: col, pos: position))
            }
        }
        
        try generate()
        try findPath()
        draw()
        
        for row in 0..<rows {
            for col in 0..<cols {
                print(cellAt(row, col).distance, terminator: " ")
            }
            print()
        }
    }
    
    func isComplete() -> Bool {
        return position == destination
    }
    
    func canMove(_ direction: directions) -> Bool {
        switch direction {
        case .up: return position.up
        case .down: return position.down
        case .left: return position.left
        case .right: return position.right
        }
    }
    
    func move(_ direction: directions) {
        switch direction {
        case .up:
            let row = position.row-1
            position = cellAt(row < 0 ? rows-1 : row, position.col)
        case .down:
            position = cellAt((position.row+1) % rows, position.col)
        case .left:
            let col = position.col-1
            position = cellAt(position.row, col < 0 ? cols-1 : col)
        case .right:
            position = cellAt(position.row, (position.col+1) % cols)
        }
    }
    
    func cellObjectSize(scale: Double = 1.0, min: Double = 20.0) -> CGSize {
        let objectSize = Double(cellSize) - Double(cellBorder)
        let minSize = min > objectSize ? objectSize : min
        let size = CGFloat(max(objectSize * scale, minSize))
        return CGSize(width: size, height: size)
    }
    
    func insert(snake: [SKSpriteNode]) {
        var i = snake.count - 1
        let size = cellObjectSize(scale: 0.8)
        for body in snake {
            body.size = size
            body.position = source.position
            body.zPosition = CGFloat(i)
            canvas.addChild(body)
            i -= 1
        }
    }
    
    func generate() throws {
        
        /* Select a starting cell at random */
        let row = Int(arc4random_uniform(UInt32(rows)))
        let col = Int(arc4random_uniform(UInt32(cols)))
        let visited = Visited(rows: rows, cols: cols)
        var availablePaths = [cellAt(row, col)]
        
        
        /* Create paths between cells until there are no new cells to visit */
        while availablePaths.count > 0 {
            
            /* Select a cell at random */
            let index = Int(arc4random_uniform(UInt32(availablePaths.count)))
            let cell = availablePaths.remove(at: index)
            visited.visit(cell)
            
            
            /* Get all neighbouring cells */
            let neighbours = self.neighbours(of: cell)
            var neighboursVisited = [MazeCell]()
            
            
            /* Split the neighbouring cells into two buckets */
            for neighbour in neighbours {
                if visited.isUnvisited(neighbour) {
                    availablePaths.append(neighbour)
                    visited.partial(neighbour)
                }
                else if visited.isVisited(neighbour) {
                    neighboursVisited.append(neighbour)
                }
            }
            
            
            /* Create a path between the cell and one of its visited neighbours */
            if(neighboursVisited.count > 0){
                let neighbourIndex = Int(arc4random_uniform(UInt32(neighboursVisited.count)))
                let neighbourCell = neighboursVisited[neighbourIndex]
                if let addPath = path(from: cell, to: neighbourCell) {
                    cell.paths |= addPath.rawValue
                    neighbourCell.paths |= addPath.opposite().rawValue
                } else {
                    throw MazeError.failed
                }
            }
        }
    }
    
    func draw() {
        canvas.removeAllActions()
        canvas.removeAllChildren()
        
        let finalRow = rows - 1
        let finalCol = cols - 1
        let offset = cellSize * 0.5
        
        var line: SKSpriteNode!
        let lineSize = cellSize + cellBorder
        let baseLine = SKSpriteNode()
        baseLine.color = UIColor.white.withAlphaComponent(0.6)
        baseLine.zPosition = 10.0
        
        for row in 0..<rows {
            for col in 0..<cols {
                let cell = cellAt(row, col)
                let point = cell.position
                
                if !cell.up {
                    line = baseLine.copy() as! SKSpriteNode
                    line.position = CGPoint(x: point.x, y: point.y + offset)
                    line.size = CGSize(width: lineSize, height: cellBorder)
                    canvas.addChild(line)
                }
                
                if !cell.left {
                    line = baseLine.copy() as! SKSpriteNode
                    line.position = CGPoint(x: point.x - offset, y: point.y)
                    line.size = CGSize(width: cellBorder, height: lineSize)
                    canvas.addChild(line)
                }
                
                if row == finalRow && !cell.down {
                    line = baseLine.copy() as! SKSpriteNode
                    line.position = CGPoint(x: point.x, y: point.y - offset)
                    line.size = CGSize(width: lineSize, height: cellBorder)
                    canvas.addChild(line)
                }
                
                if col == finalCol && !cell.right {
                    line = baseLine.copy() as! SKSpriteNode
                    line.position = CGPoint(x: point.x + offset, y: point.y)
                    line.size = CGSize(width: cellBorder, height: lineSize)
                    canvas.addChild(line)
                }
            }
        }
        
        let assets = Asset()
        let dst = SKSpriteNode(imageNamed: assets.gem(.white))
        dst.size = cellObjectSize(scale: 0.6)
        dst.position = destination.position
        dst.zPosition = 10.0
        canvas.addChild(dst)
    }
    
    func path(from: MazeCell, to: MazeCell) -> directions? {
        if from.row > to.row {
            return directions.up
        }
        if from.row < to.row {
            return directions.down
        }
        if from.col > to.col {
            return directions.left
        }
        if from.col < to.col {
            return directions.right
        }
        return nil
    }
    
    func paths(from cell: MazeCell) -> [MazeCell] {
        var paths = [MazeCell]()

        if cell.up {
            paths.append(cellAt(cell.row-1, cell.col))
        }
        if cell.down {
            paths.append(cellAt(cell.row+1, cell.col))
        }
        if cell.left {
            paths.append(cellAt(cell.row, cell.col-1))
        }
        if cell.right {
            paths.append(cellAt(cell.row, cell.col+1))
        }
        
        return paths
    }
    
    func neighbours(of cell: MazeCell) -> [MazeCell] {
        let row = cell.row
        let col = cell.col
        var neighbours = [MazeCell]()
        
        if inBounds(row-1, col) {
            neighbours.append(cellAt(row-1, col))
        }
        if inBounds(row+1, col) {
            neighbours.append(cellAt(row+1, col))
        }
        if inBounds(row, col-1) {
            neighbours.append(cellAt(row, col-1))
        }
        if inBounds(row, col+1) {
            neighbours.append(cellAt(row, col+1))
        }
        
        return neighbours
    }
    
    func bfs(_ src: MazeCell) -> MazeCell {
        
        let visited = Visited(rows: rows, cols: cols)
        let queue = List<MazeCell>()
        queue.push_back(src)
        var node = src
        
        while !queue.isEmpty {
            node = queue.pop_front()
            visited.visit(node)
            let paths = self.paths(from: node)
            for cell in paths {
                if visited.isUnvisited(cell) {
                    visited.partial(cell)
                    queue.push_back(cell)
                    cell.predecessor = node
                }
            }
        }
        
        return node
    }
    
    func bfs(_ src: MazeCell, avoid: MazeCell?) -> List<MazeCell> {
        
        var path = List<MazeCell>()
        
        if src.distance > src.predecessor?.distance ?? Int.max, (avoid == nil || src.predecessor! != avoid!) {
            path.push_back(src.predecessor!)
            return path
        }
        
        var visited = Visited(rows: rows, cols: cols)
        var predecessors = Array<MazeCell?>(repeating: nil, count: rows*cols)
        predecessors[src.row*cols+src.col] = avoid
        let queue = List<MazeCell>()
        queue.push_back(src)
        
        
        while !queue.isEmpty {
            var node: MazeCell = queue.pop_front()
            let paths = self.paths(from: node)
            visited.visit(node)
            
            for cell in paths {
                
                let cpd = predecessors[node.row*cols+node.col]
                if cpd == nil || cpd! != cell {
                    
                    predecessors[cell.row*cols+cell.col] = node
                    
                    if node.distance > cell.distance {
                        var predecessor = cell
                        while(predecessor != src) {
                            path.push_front(predecessor)
                            predecessor = predecessors[predecessor.row*cols+predecessor.col]!
                        }
                        
                    }

                    if visited.isUnvisited(cell) {
                        visited.partial(cell)
                        queue.push_back(cell)
                    }
                    
                }
                
            }
        }
        
        return path
    }

    func findPath() throws {
        destination = bfs(maze.first!)
        source = dijkstra(destination)
        position = source
        if source == destination {
            throw MazeError.failed
        }
    }

    func relax(from: MazeCell, to: MazeCell) -> Bool {
        if to.distance > from.distance + 1 {
            to.distance = from.distance + 1
            to.predecessor = from
            return true
        }
        return false
    }
    
    func dijkstra(_ destination: MazeCell) -> MazeCell {
        
        let heap = MinHeap(rows: rows, cols: cols)
        var source = destination
        destination.distance = 0
        heap.insert(source)
        
        while !heap.isEmpty {
            let node = heap.remove()
            let paths = self.paths(from: node)
            for cell in paths {
                if relax(from: node, to: cell) {
                    heap.insert(cell)
                    if source.distance < cell.distance {
                        source = cell
                    }
                }
            }
        }
        return source
    }
    
    
    func findPath(direction: directions?) -> List<MazeCell> {
        var row = position.row
        var col = position.col
        var avoid: MazeCell?
        
        if let opposite = direction?.opposite() {
            switch opposite {
            case .up: row -= 1
            case .down: row += 1
            case .left: col -= 1
            case .right: col += 1
            }
            if inBounds(row, col) {
                avoid = cellAt(row, col)
            }
        }
        
        return bfs(position, avoid: avoid)
    }
    
    
    func cellAt(_ row: Int, _ col: Int) -> MazeCell {
        return maze[row*cols+col]
    }
    
    func inBounds(_ row: Int, _ col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < rows && col < cols
    }
    
    func inRange(_ cell: MazeCell, minRow: Int, maxRow: Int, minCol: Int, maxCol: Int) -> Bool {
        return cell.row >= minRow && cell.row <= maxRow && cell.col >= minCol && cell.col <= maxCol
    }
    
    func translate(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: cellZeroZeroCentre.x + CGFloat(col) * cellSize,
            y: cellZeroZeroCentre.y - CGFloat(row) * cellSize
        )
    }
    
};
