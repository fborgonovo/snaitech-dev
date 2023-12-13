import tensorflow as tf

c1 = tf.constant([[1,2,3], [1,2,3]]);
c2 = tf.constant([[3,4,5], [3,4,5]]);

result = tf.add(c1, c2);

tf.print(result)
tf.rank