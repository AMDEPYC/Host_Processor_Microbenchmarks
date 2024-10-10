#include <assert.h>
#include <mpi.h>
#include <string>

class deviceProp {
public:
  std::string device_name;
  int device_id;
  deviceProp() = default;
  int smp_count;
  int max_thread_per_block;
  unsigned int global_mem;
  int compute_cap_major;
  int compute_cap_minor;
  int clock;
  int engine_count;
  void getDeviceProp(int device_id);
};

struct nodalDeviceInfo {
  int rank;
  int node_id; /*!<   */
  MPI_Comm nodal_comm;
  int nodal_comm_size;
  int nodal_rank;
  int device_count;
  deviceProp *prop;
  nodalDeviceInfo();
  void getRank();
  void bind();
  void bindOne2One();
  void checkP2P();
  ~nodalDeviceInfo();
};
