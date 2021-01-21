import Combine
import Foundation

extension Future {
    convenience init<Context>(execute: @autoclosure @escaping () -> Output,
                              on context: Context)
    where Context: Scheduler
    {
        self.init(execute: execute, on: context)
    }

    convenience init<Context>(execute: @escaping () -> Output,
                              on context: Context)
    where Context: Scheduler
    {
        self.init { promise in
            context.schedule {
                promise(.success(execute()))
            }
        }
    }

    convenience init<Context>(execute: @autoclosure @escaping () -> Result<Output, Failure>,
                              on context: Context)
    where Context: Scheduler
    {
        self.init { promise in
            context.schedule {
                promise(execute())
            }
        }
    }
}
