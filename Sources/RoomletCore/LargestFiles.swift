import Foundation

/// A min-heap retains the largest on-disk estimates among all visited files.
struct LargestFiles {
    let limit: Int
    private(set) var heap: [ScannedFile] = []

    static func rank(_ file: ScannedFile) -> Int64 { file.allocatedBytes ?? file.logicalBytes }

    private static func precedes(_ lhs: ScannedFile, _ rhs: ScannedFile) -> Bool {
        rank(lhs) == rank(rhs) ? lhs.relativePath > rhs.relativePath : rank(lhs) < rank(rhs)
    }

    mutating func insert(_ file: ScannedFile) {
        if heap.count < limit {
            heap.append(file)
            var child = heap.count - 1
            while child > 0 {
                let parent = (child - 1) / 2
                guard Self.precedes(heap[child], heap[parent]) else { break }
                heap.swapAt(child, parent); child = parent
            }
        } else if let smallest = heap.first, Self.precedes(smallest, file) {
            heap[0] = file
            var parent = 0
            while parent * 2 + 1 < heap.count {
                let left = parent * 2 + 1, right = left + 1
                let child = right < heap.count && Self.precedes(heap[right], heap[left]) ? right : left
                guard Self.precedes(heap[child], heap[parent]) else { break }
                heap.swapAt(parent, child); parent = child
            }
        }
    }

    func sorted() -> [ScannedFile] {
        heap.sorted { Self.rank($0) == Self.rank($1) ? $0.relativePath < $1.relativePath : Self.rank($0) > Self.rank($1) }
    }
}
