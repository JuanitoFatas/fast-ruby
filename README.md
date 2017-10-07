Fast Ruby [![Build Status](https://travis-ci.org/JuanitoFatas/fast-ruby.svg?branch=travis)](https://travis-ci.org/JuanitoFatas/fast-ruby)
=======================================================================================================================================================================

In [Erik Michaels-Ober](https://github.com/sferik)'s great talk, 'Writing Fast Ruby': [Video @ Baruco 2014](https://www.youtube.com/watch?v=fGFM_UrSp70), [Slide](https://speakerdeck.com/sferik/writing-fast-ruby), he presented us with many idioms that lead to faster running Ruby code. He inspired me to document these to let more people know. I try to link to real commits so people can see that this can really have benefits in the real world. **This does not mean you can always blindly replace one with another. It depends on the context (e.g. `gsub` versus `tr`). Friendly reminder: Use with caution!**

Each idiom has a corresponding code example that resides in [code](code).

All results listed in README.md are running with Ruby 2.2.0p0 on OS X 10.10.1. Machine information: MacBook Pro (Retina, 15-inch, Mid 2014), 2.5 GHz Intel Core i7, 16 GB 1600 MHz DDR3. Your results may vary, but you get the idea. : )

You can checkout [the travis build](https://travis-ci.org/JuanitoFatas/fast-ruby) for these benchmark results ran against different Ruby implementations.

**Let's write faster code, together! <3**

Analyze your code
-----------------

Checkout the [fasterer](https://github.com/DamirSvrtan/fasterer) project - it's a static analysis that checks speed idioms written in this repo.

Measurement Tool
-----------------

Use [benchmark-ips](https://github.com/evanphx/benchmark-ips) (2.0+).

### Template

```ruby
require "benchmark/ips"

def fast
end

def slow
end

Benchmark.ips do |x|
  x.report("fast code description") { fast }
  x.report("slow code description") { slow }
  x.compare!
end
```

Idioms
------

### Index

- [General](#general)
- [Array](#array)
- [Enumerable](#enumerable)
- [Hash](#hash)
- [Proc & Block](#proc--block)
- [String](#string)
- [Range](#range)

### General

##### Parallel Assignment vs Sequential Assignment [code](code/general/assignment.rb)

[Read the rationale here](https://github.com/JuanitoFatas/fast-ruby/pull/50#issue-98586885).

```
$ ruby -v code/general/assignment.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
 Parallel Assignment   149.201k i/100ms
Sequential Assignment
                       142.545k i/100ms
-------------------------------------------------
 Parallel Assignment      7.687M (± 6.9%) i/s -     38.345M
Sequential Assignment
                          6.320M (± 8.5%) i/s -     31.360M

Comparison:
 Parallel Assignment:  7686954.1 i/s
Sequential Assignment:  6320425.6 i/s - 1.22x slower
```

##### `begin...rescue` vs `respond_to?` for Control Flow [code](code/general/begin-rescue-vs-respond-to.rb)

```
$ ruby -v code/general/begin-rescue-vs-respond-to.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
      begin...rescue    29.452k i/100ms
         respond_to?   106.528k i/100ms
-------------------------------------------------
      begin...rescue    371.591k (± 5.4%) i/s -      1.855M
         respond_to?      3.277M (± 7.5%) i/s -     16.299M

Comparison:
         respond_to?:  3276972.3 i/s
      begin...rescue:   371591.0 i/s - 8.82x slower
```

##### `define_method` vs `module_eval` for Defining Methods [code](code/general/define_method-vs-module-eval.rb)

```
$ ruby -v code/general/define_method-vs-module-eval.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
module_eval with string 125.000  i/100ms
       define_method    138.000  i/100ms
-------------------------------------------------
module_eval with string   1.130k (±20.3%) i/s -      5.500k
       define_method      1.346k (±25.9%) i/s -      6.348k

Comparison:
       define_method:        1345.6 i/s
module_eval with string:     1129.7 i/s - 1.19x slower
```

##### `raise` vs `E2MM#Raise` for raising (and defining) exeptions  [code](code/general/raise-vs-e2mmap.rb)

Ruby's [Exception2MessageMapper module](http://ruby-doc.org/stdlib-2.2.0/libdoc/e2mmap/rdoc/index.html) allows one to define and raise exceptions with predefined messages.

```
$ ruby -v code/general/raise-vs-e2mmap.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]

Calculating -------------------------------------
Ruby exception: E2MM#Raise
                         2.865k i/100ms
Ruby exception: Kernel#raise
                        42.215k i/100ms
-------------------------------------------------
Ruby exception: E2MM#Raise
                         27.270k (± 8.8%) i/s -    137.520k
Ruby exception: Kernel#raise
                        617.446k (± 7.9%) i/s -      3.082M

Comparison:
Ruby exception: Kernel#raise:   617446.2 i/s
Ruby exception: E2MM#Raise:    27269.8 i/s - 22.64x slower

Calculating -------------------------------------
Custom exception: E2MM#Raise
                         2.807k i/100ms
Custom exception: Kernel#raise
                        45.313k i/100ms
-------------------------------------------------
Custom exception: E2MM#Raise
                         29.005k (± 7.2%) i/s -    145.964k
Custom exception: Kernel#raise
                        589.149k (± 7.8%) i/s -      2.945M

Comparison:
Custom exception: Kernel#raise:   589148.7 i/s
Custom exception: E2MM#Raise:    29004.8 i/s - 20.31x slower
```

##### `loop` vs `while true` [code](code/general/loop-vs-while-true.rb)

```
$ ruby -v code/general/loop-vs-while-true.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-linux]

Calculating -------------------------------------
          While Loop     1.000  i/100ms
         Kernel loop     1.000  i/100ms
-------------------------------------------------
          While Loop      0.536  (± 0.0%) i/s -      3.000  in   5.593042s
         Kernel loop      0.223  (± 0.0%) i/s -      2.000  in   8.982355s

Comparison:
          While Loop:        0.5 i/s
         Kernel loop:        0.2 i/s - 2.41x slower
```

#### Method Invocation

##### `call` vs `send` vs `method_missing` [code](code/method/call-vs-send-vs-method_missing.rb)

```
$ ruby -v code/method/call-vs-send-vs-method_missing.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
                call   115.094k i/100ms
                send   105.258k i/100ms
      method_missing   100.762k i/100ms
-------------------------------------------------
                call      3.811M (± 5.9%) i/s -     18.991M
                send      3.244M (± 7.2%) i/s -     16.210M
      method_missing      2.729M (± 9.8%) i/s -     13.401M

Comparison:
                call:  3811183.4 i/s
                send:  3244239.1 i/s - 1.17x slower
      method_missing:  2728893.0 i/s - 1.40x slower
```

##### Normal way to apply method vs `&method(...)` [code](code/general/block-apply-method.rb)

```
$ ruby -v code/general/block-apply-method.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
              normal    85.749k i/100ms
             &method    35.529k i/100ms
-------------------------------------------------
              normal      1.867M (± 7.6%) i/s -      9.347M
             &method    467.095k (± 6.4%) i/s -      2.345M

Comparison:
              normal:  1866669.5 i/s
             &method:   467095.4 i/s - 4.00x slower
```

##### Function with single Array argument vs splat arguments [code](code/general/array-argument-vs-splat-arguments.rb)

```
$ ruby -v code/general/array-argument-vs-splat-arguments.rb
ruby 2.1.7p400 (2015-08-18 revision 51632) [x86_64-linux-gnu]
Calculating -------------------------------------
Function with single Array argument
                       157.231k i/100ms
Function with splat arguments
                         4.983k i/100ms
-------------------------------------------------
Function with single Array argument
                          5.581M (± 2.0%) i/s -     27.987M
Function with splat arguments
                         54.428k (± 3.3%) i/s -    274.065k

Comparison:
Function with single Array argument:  5580972.6 i/s
Function with splat arguments:    54427.7 i/s - 102.54x slower

```

##### Hash vs OpenStruct on access assuming you already have a Hash or an OpenStruct [code](code/general/hash-vs-openstruct-on-access.rb)

```
$ ruby -v code/general/hash-vs-openstruct-on-access.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]

Calculating -------------------------------------
                Hash   128.344k i/100ms
          OpenStruct   110.723k i/100ms
-------------------------------------------------
                Hash      5.279M (± 7.0%) i/s -     26.311M
          OpenStruct      3.048M (± 7.0%) i/s -     15.169M

Comparison:
                Hash:  5278844.0 i/s
          OpenStruct:  3048139.8 i/s - 1.73x slower
```

##### Hash vs OpenStruct (creation) [code](code/general/hash-vs-openstruct.rb)

```
$ ruby -v code/general/hash-vs-openstruct.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]

Calculating -------------------------------------
                Hash    75.510k i/100ms
          OpenStruct     9.126k i/100ms
-------------------------------------------------
                Hash      1.604M (±11.0%) i/s -      7.929M
          OpenStruct     96.855k (± 9.9%) i/s -    483.678k

Comparison:
                Hash:  1604259.1 i/s
          OpenStruct:    96855.3 i/s - 16.56x slower
```

##### Kernel#format vs Float#round().to_s [code](code/general/format-vs-round-and-to-s.rb)

```
$ ruby -v code/general/format-vs-round-and-t
o-s.rb
ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-darwin15]
Warming up --------------------------------------
         Float#round   106.645k i/100ms
       Kernel#format    84.304k i/100ms
            String#%    78.635k i/100ms
Calculating -------------------------------------
         Float#round      1.570M (± 3.2%) i/s - 7.892M in   5.030672s
       Kernel#format      1.144M (± 3.0%) i/s - 5.733M in   5.015621s
            String#%      1.047M (± 4.2%) i/s - 5.269M in   5.042970s

Comparison:
         Float#round:  1570411.4 i/s
       Kernel#format:  1144036.6 i/s - 1.37x  slower
            String#%:  1046689.1 i/s - 1.50x  slower
```

### Array

##### `Array#bsearch` vs `Array#find` [code](code/array/bsearch-vs-find.rb)

**WARNING:** `bsearch` ONLY works on *sorted array*. More details please see [#29](https://github.com/JuanitoFatas/fast-ruby/issues/29).

```
$ ruby -v code/array/bsearch-vs-find.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
                find     1.000  i/100ms
             bsearch    42.216k i/100ms
-------------------------------------------------
                find      0.184  (± 0.0%) i/s -      1.000  in   5.434758s
             bsearch    577.301k (± 6.6%) i/s -      2.913M

Comparison:
             bsearch:   577300.7 i/s
                find:        0.2 i/s - 3137489.63x slower
```

##### `Array#length` vs `Array#size` vs `Array#count` [code](code/array/length-vs-size-vs-count.rb)

Use `#length` when you only want to know how many elements in the array, `#count` could also achieve this. However `#count` should be use for counting specific elements in array. [Note `#size` is an alias of `#length`](https://github.com/ruby/ruby/blob/f8fb526ad9e9f31453bffbc908b6a986736e21a7/array.c#L5817-L5818).

```
$ ruby -v code/array/length-vs-size-vs-count.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
        Array#length   172.998k i/100ms
          Array#size   168.130k i/100ms
         Array#count   164.911k i/100ms
-------------------------------------------------
        Array#length     11.394M (± 6.1%) i/s -     56.743M
          Array#size     11.303M (± 6.5%) i/s -     56.324M
         Array#count      9.195M (± 8.6%) i/s -     45.680M

Comparison:
        Array#length: 11394036.7 i/s
          Array#size: 11302701.1 i/s - 1.01x slower
         Array#count:  9194976.2 i/s - 1.24x slower
```

##### `Array#shuffle.first` vs `Array#sample` [code](code/array/shuffle-first-vs-sample.rb)

> `Array#shuffle` allocates an extra array. <br>
> `Array#sample` indexes into the array without allocating an extra array. <br>
> This is the reason why Array#sample exists. <br>
> —— @sferik [rails/rails#17245](https://github.com/rails/rails/pull/17245)

```
$ ruby -v code/array/shuffle-first-vs-sample.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
 Array#shuffle.first    25.406k i/100ms
        Array#sample   125.101k i/100ms
-------------------------------------------------
 Array#shuffle.first    304.341k (± 4.3%) i/s -      1.524M
        Array#sample      5.727M (± 8.6%) i/s -     28.523M

Comparison:
        Array#sample:  5727032.0 i/s
 Array#shuffle.first:   304341.1 i/s - 18.82x slower
```

##### `Array#[](0)` vs `Array#first` [code](code/array/array-first-vs-index.rb)

```
$ ruby -v code/array/array-first-vs-index.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
           Array#[0]   152.751k i/100ms
         Array#first   148.088k i/100ms
-------------------------------------------------
           Array#[0]      8.614M (± 7.0%) i/s -     42.923M
         Array#first      7.465M (±10.7%) i/s -     36.874M

Comparison:
           Array#[0]:  8613583.7 i/s
         Array#first:  7464526.6 i/s - 1.15x slower
```

##### `Array#[](-1)` vs `Array#last` [code](code/array/array-last-vs-index.rb)

```
$ ruby -v code/array/array-last-vs-index.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
            Array#[-1]   151.940k i/100ms
          Array#last   153.371k i/100ms
-------------------------------------------------
            Array#[-1]      8.582M (± 4.6%) i/s -     42.847M
          Array#last      7.639M (± 5.7%) i/s -     38.189M

Comparison:
            Array#[-1]:  8582074.3 i/s
          Array#last:  7639254.5 i/s - 1.12x slower
```

##### `Array#insert` vs `Array#unshift` [code](code/array/insert-vs-unshift.rb)

```
$ ruby -v code/array/insert-vs-unshift.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin10.0]
Calculating -------------------------------------
       Array#unshift     4.000  i/100ms
        Array#insert     1.000  i/100ms
-------------------------------------------------
       Array#unshift     44.947  (± 6.7%) i/s -    224.000
        Array#insert      0.171  (± 0.0%) i/s -      1.000  in   5.841595s

Comparison:
       Array#unshift:       44.9 i/s
        Array#insert:        0.2 i/s - 262.56x slower
```

### Enumerable

##### `Enumerable#each + push` vs `Enumerable#map` [code](code/enumerable/each-push-vs-map.rb)

```
$ ruby -v code/enumerable/each-push-vs-map.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
   Array#each + push     9.025k i/100ms
           Array#map    13.947k i/100ms
-------------------------------------------------
   Array#each + push     99.634k (± 3.2%) i/s -    505.400k
           Array#map    158.091k (± 4.2%) i/s -    794.979k

Comparison:
           Array#map:   158090.9 i/s
   Array#each + push:    99634.2 i/s - 1.59x slower
```

##### `Enumerable#each` vs `for` loop [code](code/enumerable/each-vs-for-loop.rb)

```
$ ruby -v code/enumerable/each-vs-for-loop.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin14]

Calculating -------------------------------------
            For loop    17.111k i/100ms
               #each    18.464k i/100ms
-------------------------------------------------
            For loop    198.517k (± 5.3%) i/s -    992.438k
               #each    208.157k (± 5.0%) i/s -      1.052M

Comparison:
               #each:   208157.4 i/s
            For loop:   198517.3 i/s - 1.05x slower
```

##### `Enumerable#each_with_index` vs `while` loop [code](code/enumerable/each_with_index-vs-while-loop.rb)

> [rails/rails#12065](https://github.com/rails/rails/pull/12065)

```
$ ruby -v code/enumerable/each_with_index-vs-while-loop.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
          While Loop    22.553k i/100ms
     each_with_index    11.963k i/100ms
-------------------------------------------------
          While Loop    240.752k (± 7.1%) i/s -      1.218M
     each_with_index    126.753k (± 5.9%) i/s -    634.039k

Comparison:
          While Loop:   240752.1 i/s
     each_with_index:   126753.4 i/s - 1.90x slower
```

##### `Enumerable#map`...`Array#flatten` vs `Enumerable#flat_map` [code](code/enumerable/map-flatten-vs-flat_map.rb)

> -- @sferik [rails/rails@3413b88](https://github.com/rails/rails/commit/3413b88), [Replace map.flatten with flat_map](https://github.com/rails/rails/commit/817fe31196dd59ee31f71ef1740122b6759cf16d), [Replace map.flatten(1) with flat_map](https://github.com/rails/rails/commit/b11ebf1d80e4fb124f0ce0448cea30988256da59)

```
$ ruby -v code/enumerable/map-flatten-vs-flat_map.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
Array#map.flatten(1)     3.315k i/100ms
   Array#map.flatten     3.283k i/100ms
      Array#flat_map     5.350k i/100ms
-------------------------------------------------
Array#map.flatten(1)     33.801k (± 4.3%) i/s -    169.065k
   Array#map.flatten     34.530k (± 6.0%) i/s -    173.999k
      Array#flat_map     55.980k (± 5.0%) i/s -    283.550k

Comparison:
      Array#flat_map:    55979.6 i/s
   Array#map.flatten:    34529.6 i/s - 1.62x slower
Array#map.flatten(1):    33800.6 i/s - 1.66x slower
```

##### `Enumerable#reverse.each` vs `Enumerable#reverse_each` [code](code/enumerable/reverse-each-vs-reverse_each.rb)

> `Enumerable#reverse` allocates an extra array.  <br>
> `Enumerable#reverse_each` yields each value without allocating an extra array. <br>
> This is the reason why `Enumerable#reverse_each` exists. <br>
> -- @sferik [rails/rails#17244](https://github.com/rails/rails/pull/17244)

```
$ ruby -v code/enumerable/reverse-each-vs-reverse_each.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
  Array#reverse.each    16.746k i/100ms
  Array#reverse_each    18.590k i/100ms
-------------------------------------------------
  Array#reverse.each    190.729k (± 4.8%) i/s -    954.522k
  Array#reverse_each    216.060k (± 4.3%) i/s -      1.078M

Comparison:
  Array#reverse_each:   216060.5 i/s
  Array#reverse.each:   190729.1 i/s - 1.13x slower
```

##### `Enumerable#detect` vs `Enumerable#select.first` [code](code/enumerable/select-first-vs-detect.rb)

```
$ ruby -v code/enumerable/select-first-vs-detect.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
Enumerable#select.first  8.515k i/100ms
   Enumerable#detect    33.885k i/100ms
-------------------------------------------------
Enumerable#select.first  89.757k (± 5.0%) i/s -      1.797M
   Enumerable#detect    434.304k (± 5.2%) i/s -      8.675M

Comparison:
   Enumerable#detect:   434304.2 i/s
Enumerable#select.first:    89757.4 i/s - 4.84x slower
```

##### `Enumerable#select.last` vs `Enumerable#reverse.detect` [code](code/enumerable/select-last-vs-reverse-detect.rb)

```
$ ruby -v code/enumerable/select-last-vs-reverse-detect.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
Enumerable#reverse.detect 62.636k i/100ms
Enumerable#select.last    11.687k i/100ms
-------------------------------------------------
Enumerable#reverse.detect 1.263M (± 8.2%) i/s -      6.326M
Enumerable#select.last  119.387k (± 5.7%) i/s -    596.037k

Comparison:
Enumerable#reverse.detect:  1263100.2 i/s
Enumerable#select.last:     119386.8 i/s - 10.58x slower
```

##### `Enumerable#sort` vs `Enumerable#sort_by` [code](code/enumerable/sort-vs-sort_by.rb)

```
$ ruby -v code/enumerable/sort-vs-sort_by.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
Enumerable#sort_by (Symbol#to_proc) 2.680k i/100ms
  Enumerable#sort_by                2.462k i/100ms
     Enumerable#sort                1.320k i/100ms
-------------------------------------------------
Enumerable#sort_by (Symbol#to_proc) 25.916k (± 4.4%) i/s -    131.320k
  Enumerable#sort_by                24.650k (± 5.1%) i/s -    125.562k
     Enumerable#sort                14.018k (± 5.6%) i/s -     69.960k

Comparison:
Enumerable#sort_by (Symbol#to_proc):    25916.1 i/s
  Enumerable#sort_by:                   24650.2 i/s - 1.05x slower
     Enumerable#sort:                   14018.3 i/s - 1.85x slower
```

##### `Enumerable#inject Symbol` vs `Enumerable#inject Proc` [code](code/enumerable/inject-symbol-vs-block.rb)

Of note, `to_proc` for 1.8.7 is considerable slower than the block format

```
$ ruby -v code/enumerable/inject-sum-vs-block.rb
ruby 2.2.4p230 (2015-12-16 revision 53155) [x86_64-darwin14]
Warming up --------------------------------------
       inject symbol     1.893k i/100ms
      inject to_proc     1.583k i/100ms
        inject block     1.390k i/100ms
Calculating -------------------------------------
       inject symbol     19.001k (± 3.8%) i/s -     96.543k
      inject to_proc     15.958k (± 3.5%) i/s -     80.733k
        inject block     14.063k (± 3.9%) i/s -     70.890k

Comparison:
       inject symbol:    19001.5 i/s
      inject to_proc:    15958.3 i/s - 1.19x slower
        inject block:    14063.1 i/s - 1.35x slower
```

### Hash

##### `Hash#[]` vs `Hash#fetch` [code](code/hash/bracket-vs-fetch.rb)

If you use Ruby 2.2, `Symbol` could be more performant than `String` as `Hash` keys.
Read more regarding this: [Symbol GC in Ruby 2.2](http://www.sitepoint.com/symbol-gc-ruby-2-2/) and [Unraveling String Key Performance in Ruby 2.2](http://www.sitepoint.com/unraveling-string-key-performance-ruby-2-2/).

```
$ ruby -v code/hash/bracket-vs-fetch.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
     Hash#[], symbol   143.850k i/100ms
  Hash#fetch, symbol   137.425k i/100ms
     Hash#[], string   143.083k i/100ms
  Hash#fetch, string   120.417k i/100ms
-------------------------------------------------
     Hash#[], symbol      7.531M (± 6.6%) i/s -     37.545M
  Hash#fetch, symbol      6.644M (± 8.2%) i/s -     32.982M
     Hash#[], string      6.657M (± 7.7%) i/s -     33.195M
  Hash#fetch, string      3.981M (± 8.7%) i/s -     19.748M

Comparison:
     Hash#[], symbol:  7531355.8 i/s
     Hash#[], string:  6656818.8 i/s - 1.13x slower
  Hash#fetch, symbol:  6643665.5 i/s - 1.13x slower
  Hash#fetch, string:  3981166.5 i/s - 1.89x slower
```

##### `Hash['key']` vs `Hash[:key]` [code](code/hash/string-keys-vs-symbol-keys.rb)

In ruby 2.3.5 *generating* Hash with Symbol keys are a bit more performant than String keys. But the difference is insignificant for Hash with 1 pair of key/value.
In ruby 2.4.2  Symbol keys are about 15%-19% faster. Using String keys can come with a small penalty, as seen below.

```
$ruby -v code/hash/string-keys-vs-symbol-keys.rb
ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin16]
Generating simple Hashes with just 1 key/value using different types of keys
Generating using implicit form
Warming up --------------------------------------
        {symbol: 42}   112.603k i/100ms
     {:symbol => 42}   113.512k i/100ms
     {'sym_str': 42}   111.994k i/100ms
    {"string" => 42}   109.474k i/100ms
    {'string' => 42}   110.688k i/100ms
Calculating -------------------------------------
        {symbol: 42}      1.731M (± 2.0%) i/s -      8.670M in   5.010332s
     {:symbol => 42}      1.714M (± 2.0%) i/s -      8.627M in   5.034970s
     {'sym_str': 42}      1.711M (± 3.5%) i/s -      8.624M in   5.046647s
    {"string" => 42}      1.508M (± 9.3%) i/s -      7.554M in   5.064608s
    {'string' => 42}      1.453M (± 5.7%) i/s -      7.305M in   5.045950s

Comparison:
        {symbol: 42}:  1731221.3 i/s
     {:symbol => 42}:  1714113.4 i/s - same-ish: difference falls within error
     {'sym_str': 42}:  1711084.8 i/s - same-ish: difference falls within error
    {"string" => 42}:  1508413.1 i/s - 1.15x  slower
    {'string' => 42}:  1452896.9 i/s - 1.19x  slower
```

However if you need to generate large Hash with 1000 key/value pairs the difference becomes more obvious. Hash with symbol keys is about 35% faster (in ruby 2.3.5 it is about 17% faster). [code](code/hash/string-keys-vs-symbol-keys-with-1000-pairs.rb)

```
$ruby -v code/hash/string-keys-vs-symbol-keys-with-1000-pairs.rb
ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin16]
Warming up --------------------------------------
         Symbol Keys   340.000  i/100ms
         String Keys   248.000  i/100ms
Calculating -------------------------------------
         Symbol Keys      3.385k (± 5.2%) i/s -     17.000k in   5.036258s
         String Keys      2.486k (± 3.9%) i/s -     12.648k in   5.095433s

Comparison:
         Symbol Keys:     3385.2 i/s
         String Keys:     2485.9 i/s - 1.36x  slower
```


##### `Hash#dig` vs `Hash#[]` vs `Hash#fetch` [code](code/hash/dig-vs-[]-vs-fetch.rb)

[Ruby 2.3 introduced `Hash#dig`](http://ruby-doc.org/core-2.3.0/Hash.html#method-i-dig) which is a readable
and performant option for retrieval from a nested hash, returning `nil` if an extraction step fails.
See [#102 (comment)](https://github.com/JuanitoFatas/fast-ruby/pull/102#issuecomment-198827506) for more info.

```
$ ruby -v code/hash/dig-vs-\[\]-vs-fetch.rb
ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-darwin15]

Calculating -------------------------------------
            Hash#dig      5.719M (± 6.1%) i/s -     28.573M in   5.013997s
             Hash#[]      6.066M (± 6.9%) i/s -     30.324M in   5.025614s
          Hash#[] ||      5.366M (± 6.5%) i/s -     26.933M in   5.041403s
          Hash#[] &&      2.782M (± 4.8%) i/s -     13.905M in   5.010328s
          Hash#fetch      4.101M (± 6.1%) i/s -     20.531M in   5.024945s
 Hash#fetch fallback      2.975M (± 5.5%) i/s -     14.972M in   5.048880s

Comparison:
             Hash#[]:  6065791.0 i/s
            Hash#dig:  5719290.9 i/s - same-ish: difference falls within error
          Hash#[] ||:  5366226.5 i/s - same-ish: difference falls within error
          Hash#fetch:  4101102.1 i/s - 1.48x slower
 Hash#fetch fallback:  2974906.9 i/s - 2.04x slower
          Hash#[] &&:  2781646.6 i/s - 2.18x slower
```

##### `Hash[]` vs `Hash#dup` [code](code/hash/bracket-vs-dup.rb)

Source: http://tenderlovemaking.com/2015/02/11/weird-stuff-with-hashes.html

> Does this mean that you should switch to Hash[]?
> Only if your benchmarks can prove that it’s a bottleneck.
> Please please please don’t change all of your code because
> this shows it’s faster. Make sure to measure your app performance first.

```
$ ruby -v code/hash/bracket-vs-dup.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
              Hash[]    29.403k i/100ms
            Hash#dup    16.195k i/100ms
-------------------------------------------------
              Hash[]    343.987k (± 8.7%) i/s -      1.735M
            Hash#dup    163.516k (±10.2%) i/s -    825.945k

Comparison:
              Hash[]:   343986.5 i/s
            Hash#dup:   163516.3 i/s - 2.10x slower
```

##### `Hash#fetch` with argument vs `Hash#fetch` + block [code](code/hash/fetch-vs-fetch-with-block.rb)

> Note that the speedup in the block version comes from avoiding repeated <br>
> construction of the argument. If the argument is a constant, number symbol or <br>
> something of that sort the argument version is actually slightly faster <br>
> See also [#39 (comment)](https://github.com/JuanitoFatas/fast-ruby/issues/39#issuecomment-103989335)

```
$ ruby -v code/hash/fetch-vs-fetch-with-block.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin13]
Calculating -------------------------------------
  Hash#fetch + const   129.868k i/100ms
  Hash#fetch + block   125.254k i/100ms
    Hash#fetch + arg   121.155k i/100ms
-------------------------------------------------
  Hash#fetch + const      7.031M (± 7.0%) i/s -     34.934M
  Hash#fetch + block      6.815M (± 4.2%) i/s -     34.069M
    Hash#fetch + arg      4.753M (± 5.6%) i/s -     23.746M

Comparison:
  Hash#fetch + const:  7030600.4 i/s
  Hash#fetch + block:  6814826.7 i/s - 1.03x slower
    Hash#fetch + arg:  4752567.2 i/s - 1.48x slower
```

##### `Hash#each_key` instead of `Hash#keys.each` [code](code/hash/keys-each-vs-each_key.rb)

> `Hash#keys.each` allocates an array of keys;  <br>
> `Hash#each_key` iterates through the keys without allocating a new array.  <br>
> This is the reason why `Hash#each_key` exists.  <br>
> —— @sferik [rails/rails#17099](https://github.com/rails/rails/pull/17099)

```
$ ruby -v code/hash/keys-each-vs-each_key.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
      Hash#keys.each    56.690k i/100ms
       Hash#each_key    59.658k i/100ms
-------------------------------------------------
      Hash#keys.each    869.262k (± 5.0%) i/s -      4.365M
       Hash#each_key      1.049M (± 6.0%) i/s -      5.250M

Comparison:
       Hash#each_key:  1049161.6 i/s
      Hash#keys.each:   869262.3 i/s - 1.21x slower
```

##### `Hash#merge!` vs `Hash#[]=` [code](code/hash/merge-bang-vs-\[\]=.rb)

```
$ ruby -v code/hash/merge-bang-vs-\[\]=.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
         Hash#merge!     1.023k i/100ms
            Hash#[]=     2.844k i/100ms
-------------------------------------------------
         Hash#merge!     10.653k (± 4.9%) i/s -     53.196k
            Hash#[]=     28.287k (±12.4%) i/s -    142.200k

Comparison:
            Hash#[]=:    28287.1 i/s
         Hash#merge!:    10653.3 i/s - 2.66x slower
```

##### `Hash#merge` vs `Hash#**other` [code](code/hash/merge-vs-double-splat-operator.rb)

```
$ ruby -v merge-vs-double-splat-operator.rb
ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-darwin15]
Warming up --------------------------------------
        Hash#**other    64.624k i/100ms
          Hash#merge    38.827k i/100ms
Calculating -------------------------------------
        Hash#**other    798.397k (± 6.9%) i/s -      4.007M in   5.053516s
          Hash#merge    434.171k (± 4.5%) i/s -      2.174M in   5.018927s

Comparison:
        Hash#**other:   798396.6 i/s
          Hash#merge:   434170.8 i/s - 1.84x  slower
```

##### `Hash#merge` vs `Hash#merge!` [code](code/hash/merge-vs-merge-bang.rb)

```
$ ruby -v code/hash/merge-vs-merge-bang.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
          Hash#merge    39.000  i/100ms
         Hash#merge!     1.008k i/100ms
-------------------------------------------------
          Hash#merge    409.610  (± 7.6%) i/s -      2.067k
         Hash#merge!      9.830k (± 5.8%) i/s -     49.392k

Comparison:
         Hash#merge!:     9830.3 i/s
          Hash#merge:      409.6 i/s - 24.00x slower
```

##### `{}#merge!(Hash)` vs `Hash#merge({})` vs `Hash#dup#merge!({})` [code](code/hash/merge-bang-vs-merge-vs-dup-merge-bang.rb)

> When we don't want to modify the original hash, and we want duplicates to be created <br>
> See [#42](https://github.com/JuanitoFatas/fast-ruby/pull/42#issue-93502261) for more details.

```
$ ruby -v code/hash/merge-bang-vs-merge-vs-dup-merge-bang.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]

Calculating -------------------------------------
{}#merge!(Hash) do end     2.006k i/100ms
        Hash#merge({})   762.000  i/100ms
   Hash#dup#merge!({})   736.000  i/100ms
-------------------------------------------------
{}#merge!(Hash) do end     20.055k (± 2.0%) i/s -    100.300k in   5.003322s
        Hash#merge({})      7.676k (± 1.2%) i/s -     38.862k in   5.063382s
   Hash#dup#merge!({})      7.440k (± 1.1%) i/s -     37.536k in   5.045851s

Comparison:
{}#merge!(Hash) do end:    20054.8 i/s
        Hash#merge({}):     7676.3 i/s - 2.61x slower
   Hash#dup#merge!({}):     7439.9 i/s - 2.70x slower
```

##### `Hash#sort_by` vs `Hash#sort` [code](code/hash/hash-key-sort_by-vs-sort.rb)

To sort hash by key.

```
$ ruby -v code/hash/hash-key-sort_by-vs-sort.rb
ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]

Calculating -------------------------------------
      sort_by + to_h    11.468k i/100ms
         sort + to_h     8.107k i/100ms
-------------------------------------------------
      sort_by + to_h    122.176k (± 6.0%) i/s -    619.272k
         sort + to_h     81.973k (± 4.7%) i/s -    413.457k

Comparison:
      sort_by + to_h:   122176.2 i/s
         sort + to_h:    81972.8 i/s - 1.49x slower
```

### Proc & Block

##### Block vs `Symbol#to_proc` [code](code/proc-and-block/block-vs-to_proc.rb)

> `Symbol#to_proc` is considerably more concise than using block syntax. <br>
> ...In some cases, it reduces the number of lines of code. <br>
> —— @sferik [rails/rails#16833](https://github.com/rails/rails/pull/16833)

```
$ ruby -v code/proc-and-block/block-vs-to_proc.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
               Block     4.632k i/100ms
      Symbol#to_proc     5.225k i/100ms
-------------------------------------------------
               Block     47.914k (± 6.3%) i/s -    240.864k
      Symbol#to_proc     54.791k (± 4.1%) i/s -    276.925k

Comparison:
      Symbol#to_proc:    54791.1 i/s
               Block:    47914.3 i/s - 1.14x slower
```

##### `Proc#call` and block arguments vs `yield`[code](code/proc-and-block/proc-call-vs-yield.rb)

In MRI Ruby, block arguments [are converted to Procs](https://www.omniref.com/ruby/2.2.0/symbols/Proc/yield?#annotation=4087638&line=711), which incurs a heap allocation.

```
$ ruby -v code/proc-and-block/proc-call-vs-yield.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin15]
Calculating -------------------------------------
          block.call    41.978k i/100ms
       block + yield    42.674k i/100ms
      block argument    41.722k i/100ms
               yield    62.681k i/100ms
-------------------------------------------------
          block.call    842.581k (±12.5%) i/s -      4.114M
       block + yield    941.468k (±11.7%) i/s -      4.651M
      block argument      1.043M (± 7.1%) i/s -      5.215M
               yield      3.828M (±11.3%) i/s -     18.930M

Comparison:
               yield:  3828436.1 i/s
      block argument:  1042509.6 i/s - 3.67x slower
       block + yield:   941467.7 i/s - 4.07x slower
          block.call:   842581.2 i/s - 4.54x slower
```


### String

##### `String#casecmp` vs `String#downcase + ==` [code](code/string/casecmp-vs-downcase-==.rb)

```
$ ruby -v code/string/casecmp-vs-downcase-\=\=.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
String#downcase + ==   101.900k i/100ms
      String#casecmp   109.828k i/100ms
-------------------------------------------------
String#downcase + ==      2.915M (± 5.4%) i/s -     14.572M
      String#casecmp      3.708M (± 6.1%) i/s -     18.561M

Comparison:
      String#casecmp:  3708258.7 i/s
String#downcase + ==:  2914767.7 i/s - 1.27x slower
```

##### String Concatenation [code](code/string/concatenation.rb)

```
$ ruby -v code/string/concatenation.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]

Warming up --------------------------------------
            String#+   149.298k i/100ms
       String#concat   151.505k i/100ms
       String#append   153.389k i/100ms
         "foo" "bar"   195.552k i/100ms
  "#{'foo'}#{'bar'}"   193.784k i/100ms
Calculating -------------------------------------
            String#+      2.977M (± 1.1%) i/s -     14.930M in   5.015179s
       String#concat      3.017M (± 1.3%) i/s -     15.150M in   5.023063s
       String#append      3.076M (± 1.2%) i/s -     15.492M in   5.037683s
         "foo" "bar"      5.370M (± 1.0%) i/s -     26.986M in   5.026271s
  "#{'foo'}#{'bar'}"      5.182M (± 4.6%) i/s -     25.967M in   5.022093s

Comparison:
         "foo" "bar":  5369594.5 i/s
  "#{'foo'}#{'bar'}":  5181745.7 i/s - same-ish: difference falls within error
       String#append:  3075719.2 i/s - 1.75x slower
       String#concat:  3016703.5 i/s - 1.78x slower
            String#+:  2977282.7 i/s - 1.80x slower
```

##### `String#match` vs `String#start_with?`/`String#end_with?` [code (start)](code/string/start-string-checking-match-vs-start_with.rb) [code (end)](code/string/end-string-checking-match-vs-end_with.rb)

> :warning: <br>
> Sometimes you cant replace regexp with `start_with?`, <br>
> for example: `"a\nb" =~ /^b/ #=> 2` but `"a\nb" =~ /\Ab/ #=> nil`.<br>
> :warning: <br>
> You can combine `start_with?` and `end_with?` to replace
> `error.path =~ /^#{path}(\.rb)?$/` to this <br>
> `error.path.start_with?(path) && error.path.end_with?('.rb', '')`<br>
> —— @igas [rails/rails#17316](https://github.com/rails/rails/pull/17316)

```
$ ruby -v code/string/start-string-checking-match-vs-start_with.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
           String#=~    56.672k i/100ms
  String#start_with?   118.308k i/100ms
-------------------------------------------------
           String#=~    919.574k (± 6.4%) i/s -      4.590M
  String#start_with?      4.177M (± 6.4%) i/s -     20.822M

Comparison:
  String#start_with?:  4177162.6 i/s
           String#=~:   919574.2 i/s - 4.54x slower
```

```
$ ruby -v code/string/end-string-checking-match-vs-end_with.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
           String#=~    53.194k i/100ms
    String#end_with?   105.871k i/100ms
-------------------------------------------------
           String#=~    891.124k (± 7.2%) i/s -      4.468M
    String#end_with?      2.942M (± 7.6%) i/s -     14.610M

Comparison:
    String#end_with?:  2942017.4 i/s
           String#=~:   891124.1 i/s - 3.30x slower
```

##### `String#start_with?` vs `String#[].==` [code](code/string/start_with-vs-substring-==.rb)

```
$ ruby -v code/string/end-string-checking-match-vs-end_with.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
  String#start_with?      2.047M (± 4.5%) i/s -     10.242M in   5.015146s
    String#[0, n] ==    711.802k (± 7.3%) i/s -      3.551M in   5.019543s
   String#[RANGE] ==    651.751k (± 6.2%) i/s -      3.296M in   5.078772s
   String#[0...n] ==    427.207k (± 5.7%) i/s -      2.136M in   5.019245s

Comparison:
  String#start_with?:  2046618.9 i/s
    String#[0, n] ==:   711802.3 i/s - 2.88x slower
   String#[RANGE] ==:   651751.2 i/s - 3.14x slower
   String#[0...n] ==:   427206.8 i/s - 4.79x slower
```

##### `Regexp#===` vs `String#match` vs `String#=~` [code ](code/string/===-vs-=~-vs-match.rb)

> :warning: <br>
> Sometimes you can't replace `match` with `=~`, <br>
> This is only useful for cases where you are checking <br>
> for a match and not using the resultant match object. <br>
> :warning: <br>
> `Regexp#===` is also faster than `String#match` but you need to switch the order of arguments.

```
$ ruby -v code/string/===-vs-=~-vs-match.rb.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
           String#=~    98.184k i/100ms
          Regexp#===    92.382k i/100ms
        String#match    83.601k i/100ms
-------------------------------------------------
           String#=~      2.442M (± 7.6%) i/s -     12.175M
          Regexp#===      2.259M (± 7.9%) i/s -     11.271M
        String#match      1.840M (± 7.3%) i/s -      9.196M

Comparison:
           String#=~:  2442335.1 i/s
          Regexp#===:  2259277.3 i/s - 1.08x slower
        String#match:  1839815.4 i/s - 1.33x slower
```

See [#59](https://github.com/JuanitoFatas/fast-ruby/pull/59) and [#62](https://github.com/JuanitoFatas/fast-ruby/pull/62) for discussions.


##### `String#gsub` vs `String#sub` vs `String#[]=` [code](code/string/gsub-vs-sub.rb)

```
$ ruby -v code/string/gsub-vs-sub.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]

Warming up --------------------------------------
         String#gsub    48.360k i/100ms
          String#sub    45.739k i/100ms
String#dup["string"]=   59.896k i/100ms
Calculating -------------------------------------
         String#gsub    647.666k (± 3.3%) i/s -      3.240M in   5.008504s
          String#sub    756.665k (± 2.0%) i/s -      3.796M in   5.019235s
String#dup["string"]=   917.873k (± 1.8%) i/s -      4.612M in   5.026253s

Comparison:
String#dup["string"]=:   917873.1 i/s
          String#sub:    756664.7 i/s - 1.21x slower
         String#gsub:    647665.6 i/s - 1.42x slower


```

##### `String#gsub` vs `String#tr` [code](code/string/gsub-vs-tr.rb)

> [rails/rails#17257](https://github.com/rails/rails/pull/17257)

```
$ ruby -v code/string/gsub-vs-tr.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
         String#gsub    38.268k i/100ms
           String#tr    83.210k i/100ms
-------------------------------------------------
         String#gsub    516.604k (± 4.4%) i/s -      2.602M
           String#tr      1.862M (± 4.0%) i/s -      9.320M

Comparison:
           String#tr:  1861860.4 i/s
         String#gsub:   516604.2 i/s - 3.60x slower
```

##### `Mutable` vs `Immutable` [code](code/string/mutable_vs_immutable_strings.rb)

```
$ ruby -v code/string/mutable_vs_immutable_strings.rb
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin14]

Calculating -------------------------------------
      Without Freeze      7.279M (± 6.6%) i/s -     36.451M in   5.029785s
         With Freeze      9.329M (± 7.9%) i/s -     46.370M in   5.001345s

Comparison:
         With Freeze:  9329054.3 i/s
      Without Freeze:  7279203.1 i/s - 1.28x slower
```


##### `String#sub!` vs `String#gsub!` vs `String#[]=` [code](code/string/sub!-vs-gsub!-vs-[]=.rb)

Note that `String#[]` will throw an `IndexError` when given string or regexp not matched.

```
$ ruby -v code/string/sub\!-vs-gsub\!-vs-\[\]\=.rb
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]

Calculating -------------------------------------
  String#['string']=    74.512k i/100ms
 String#sub!'string'    52.801k i/100ms
String#gsub!'string'    34.480k i/100ms
  String#[/regexp/]=    55.325k i/100ms
 String#sub!/regexp/    45.770k i/100ms
String#gsub!/regexp/    27.665k i/100ms
-------------------------------------------------
  String#['string']=      1.215M (± 6.2%) i/s -      6.110M
 String#sub!'string'    752.731k (± 6.2%) i/s -      3.749M
String#gsub!'string'    481.183k (± 4.4%) i/s -      2.414M
  String#[/regexp/]=    840.615k (± 5.3%) i/s -      4.205M
 String#sub!/regexp/    663.075k (± 7.8%) i/s -      3.295M
String#gsub!/regexp/    342.004k (± 7.5%) i/s -      1.715M

Comparison:
  String#['string']=:  1214845.5 i/s
  String#[/regexp/]=:   840615.2 i/s - 1.45x slower
 String#sub!'string':   752731.4 i/s - 1.61x slower
 String#sub!/regexp/:   663075.3 i/s - 1.83x slower
String#gsub!'string':   481183.5 i/s - 2.52x slower
String#gsub!/regexp/:   342003.8 i/s - 3.55x slower
```

##### `String#sub` vs `String#chomp` [code](code/string/sub-vs-chomp.rb)

Note that this can only be used for removing characters from the end of a string.

```
$ ruby -v code/string/sub-vs-chomp.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin13]
Calculating -------------------------------------
  String#sub/regexp/    42.816k i/100ms
String#chomp'string'    94.851k i/100ms
-------------------------------------------------
  String#sub/regexp/    660.509k (± 8.0%) i/s -      3.297M
String#chomp'string'      2.803M (± 8.0%) i/s -     13.943M

Comparison:
String#chomp'string':  2803443.5 i/s
  String#sub/regexp/:   660508.7 i/s - 4.24x slower
```

##### `attr_accessor` vs `getter and setter` [code](code/general/attr-accessor-vs-getter-and-setter.rb)

> https://www.omniref.com/ruby/2.2.0/files/method.h?#annotation=4081781&line=47

```
$ ruby -v code/general/attr-accessor-vs-getter-and-setter.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]
Calculating -------------------------------------
   getter_and_setter    61.240k i/100ms
       attr_accessor    66.535k i/100ms
-------------------------------------------------
   getter_and_setter      1.660M (± 9.7%) i/s -      8.267M
       attr_accessor      1.865M (± 9.2%) i/s -      9.248M

Comparison:
       attr_accessor:  1865408.4 i/s
   getter_and_setter:  1660021.9 i/s - 1.12x slower
```


### Range

#### `cover?` vs `include?` [code](code/range/cover-vs-include.rb)

`cover?` only check if it is within the start and end, `include?` needs to traverse the whole range.

```
$ ruby -v code/range/cover-vs-include.rb
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-linux]

Calculating -------------------------------------
        range#cover?    85.467k i/100ms
      range#include?     7.720k i/100ms
       range#member?     7.783k i/100ms
       plain compare   102.189k i/100ms
-------------------------------------------------
        range#cover?      1.816M (± 5.6%) i/s -      9.060M
      range#include?     83.344k (± 5.0%) i/s -    416.880k
       range#member?     82.654k (± 5.0%) i/s -    412.499k
       plain compare      2.581M (± 6.2%) i/s -     12.876M

Comparison:
       plain compare:  2581211.8 i/s
        range#cover?:  1816038.5 i/s - 1.42x slower
      range#include?:    83343.9 i/s - 30.97x slower
       range#member?:    82654.1 i/s - 31.23x slower
```


## Less idiomatic but with significant performance ruby

Checkout: https://github.com/JuanitoFatas/fast-ruby/wiki/Less-idiomatic-but-with-significant-performance-difference


## Submit New Entry

Please! [Edit this README.md](https://github.com/JuanitoFatas/fast-ruby/edit/master/README.md) then [Submit a Awesome Pull Request](https://github.com/JuanitoFatas/fast-ruby/pulls)!


## Something went wrong

Code example is wrong? :cry: Got better example? :heart_eyes: Excellent!

[Please open an issue](https://github.com/JuanitoFatas/fast-ruby/issues/new) or [Open a Pull Request](https://github.com/JuanitoFatas/fast-ruby/pulls) to fix it.

Thank you in advance! :wink: :beer:


## One more thing

[Share this with your #Rubyfriends! <3](https://twitter.com/intent/tweet?url=http%3A%2F%2Fgit.io%2F4U3xdw&text=Fast%20Ruby%20--%20Common%20Ruby%20Idioms%20inspired%20by%20%40sferik&original_referer=&via=juanitofatas&hashtags=#RubyFriends)

Brought to you by [@JuanitoFatas](https://twitter.com/juanitofatas)

Feel free to talk with me on Twitter! <3


## Also Checkout

- [Derailed Benchmarks](https://github.com/schneems/derailed_benchmarks)

  Go faster, off the Rails - Benchmarks for your whole Rails app

- [Benchmarking Ruby](https://speakerdeck.com/davystevenson/benchmarking-ruby)

  Talk by Davy Stevenson @ RubyConf 2014.

- [davy/benchmark-bigo](https://github.com/davy/benchmark-bigo)

  Provides Big O notation benchmarking for Ruby.

- [The Ruby Challenge](https://therubychallenge.com/)

  Talk by Prem Sichanugrist @ Ruby Kaigi 2014.

- [Fasterer](https://github.com/DamirSvrtan/fasterer)

  Make your Rubies go faster with this command line tool.


## License

![CC-BY-SA](CC-BY-SA.png)

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).


## Code License

### CC0 1.0 Universal

To the extent possible under law, @JuanitoFatas has waived all copyright and related or neighboring rights to "fast-ruby".

This work belongs to the community.
