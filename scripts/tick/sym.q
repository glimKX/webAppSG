/This is for loading of the empty schema for tick.q

/Init base tables, trade and quotes
trade:flip `time`sym`size`price!"NSJF"$\:();
quote:flip `time`sym`bidSize`bidPrice`askSize`askPrice!"NSJFJF"$\:();
aggreg:flip `time`sym`maxPrice`minPrice`tradedVol`maxBid`minAsk!"NSFFJFF"$\:();
