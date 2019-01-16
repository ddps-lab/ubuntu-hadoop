These files are for building docker files and make containers easily.  
run_hadoop is script file for making containers.

---

#### 클러스터 만드는 방법
1. overlay network 만들기
2. run_hadoop script 실행하여 master 노드와 slave 노드들 만들기
3. master 노드에서 start-all.sh 실행하기

---

##### 1. overlay network 만드는 방법

Docker Container Orchestration 이 적용된 여러 서버에서, 각 서버의 컨테이너들이 소통하기 위해 overlay network (multi-host network)를 만들어주어야 한다.  
아래 명령어를 통해 overlay network 를 만들 수 있다.

```sudo docker network create -d=overlay --attachable [네트워크 이름]```

예)

```sudo docker network create -d=overlay --attachable my-net```

**overlay network는 worker node 에서는 만들 수 없고 manager node 에서 만들어야 함*

---

##### 2. run_hadoop 실행 방법

서버가 3대(server1, server2, server3)가 있다고 가정하자.  
각각의 서버에 들어가서 아래 명령어를 통해 run_hadoop 을 실행한다.

```./run_hadoop [네트워크 이름] [master 컨테이너 만듦 여부] [만들 slave 컨테이너의 첫 범위] [만들 slave 컨테이너의 마지막 범위] [총 slaves 컨테이너 개수]```

예) 

server1 에서 ```./run_hadoop my-net 1 1 3 10```  
server2 에서 ```./run_hadoop my-net 0 4 6 10```  
server3 에서 ```./run_hadoop my-net 0 7 10 10```

설명)

**server1 에서 실행한 명령어**의 경우, 두번째 파라미터가 1 이기 때문에 master 컨테이너를 만들고,  
세번째, 네번째 파라미터가 1,3 이기 때문에 slaves 3개, 즉 slave1, slave2, slave3 컨테이너들을 만들고,  
첫번째 파라미터 값에 따라 my-net이라는 네트워크에 연결한다.  
master 컨테이너를 만들 때(두번째 파라미터가 1일 때) 마지막 파라미터 값에 따라,  
workers file에 slaves 이름을 1부터 10까지 순서대로 10개(slave1, slave2, .. slave10) 추가한다.  
결과적으로 master, slave1, slave2, slave3 컨테이너가 my-net 이라는 네트워크에 묶여서 실행된다.

**server2 에서 실행한 명령어**의 경우, 두번째 파라미터가 0 이기 때문에 master 컨테이너는 만들지 않고,  
세번째, 네번째 파라미터가 4, 6 이기 때문에 slaves 3개, 즉 slave4, slave5, slave6 컨테이너를 만들고,  
첫번째 파라미터 값에 따라 my-net 이라는 네트워크에 연결한다.  
결과적으로 slave4, slave5, slave6 컨테이너가 my-net 이라는 네트워크에 묶여서 실행된다.

**server3 에서 실행한 명령어**의 경우, 두번째 파라미터가 0 이기 때문에 master 컨테이너는 만들지 않고,  
세번째, 네번째 파라미터가 7, 10 이기 때문에 slaves 4개, 즉 slave7, slave8, slave9, slave10 컨테이너를 만들고,  
첫번째 파라미터 값에 따라 my-net 이라는 네트워크에 연결한다.  
결과적으로 slave7, slave8, slave9, slave10 컨테이너가 my-net 이라는 네트워크에 묶여서 실행된다.

---

##### 3. master 노드에서 start-all.sh 실행하는 방법

master 노드에 들어간다.

```sudo docker exec -it master bash```

아래 명령어로 start-all.sh 를 실행한다.

```start-all.sh```

---

reference

https://hub.docker.com/r/sequenceiq/spark/  
https://github.com/sequenceiq/docker-spark

