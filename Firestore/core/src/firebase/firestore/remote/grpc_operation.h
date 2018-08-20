/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_GRPC_OPERATION_H_
#define FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_GRPC_OPERATION_H_

#include <utility>

#include "grpcpp/support/byte_buffer.h"

#include "Firestore/core/src/firebase/firestore/util/status.h"

namespace firebase {
namespace firestore {
namespace remote {

/** Observer that gets notified of events on a GRPC stream. */
class GrpcStreamObserver {
 public:
  virtual ~GrpcStreamObserver() {
  }

  // Stream has been successfully established.
  virtual void OnStreamStart() = 0;
  // A message has been received from the server.
  virtual void OnStreamRead(const grpc::ByteBuffer& message) = 0;
  // The stream is ready to accept another write operation. Note that this
  // doesn't mean the write has been sent on the wire yet.
  virtual void OnStreamWrite() = 0;
  // Connection has been broken, perhaps by the server.
  virtual void OnStreamError(const util::Status& status) = 0;

  // Incrementally increasing number used to check whether this observer is
  // still interested in the completion of previously executed operations.
  // GRPC streams are expected to be tagged by a generation number corresponding
  // to the observer; once the observer is no longer interested in that stream,
  // it should increase its generation number.
  virtual int generation() const = 0;
};

/**
 * A loose interface for an operation submitted to the gRPC completion queue.
 */
class GrpcOperation {
 public:
  virtual ~GrpcOperation() {
  }

  /**
   * Executes the asynchronous gRPC operation. The operation is expected to be
   * put on the completion queue by this function.
   */
  virtual void Execute() = 0;

  /**
   * Must to be called once the operation is retrieved from the completion
   * queue, and provided with a boolean to indicate whether the operation has
   * completed successfully. A false value of `ok` means unrecoverable failure.
   */
  virtual void Complete(bool ok) = 0;
};

}  // namespace remote
}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_GRPC_OPERATION_H_
