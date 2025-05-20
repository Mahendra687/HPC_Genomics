import pandas as pd

data = {
    'Sample': [
        "Alzheimer's whole brain",
        "Normal brain, temporal lobe",
        "Alzheimer's brain, temporal lobe",
        "Normal brain, frontal lobe",
        "Alzheimer's brain, frontal lobe",
        "Normal whole brain"
    ],
    'SRR_ID': [
        "SRR087416", "SRR085471", "SRR085473",
        "SRR085474", "SRR085726", "SRR085725"
    ],
    'Spots': [
        14720816, 15256752, 14227702,
        15772947, 15228832, 13442077
    ],
    'Bases': [
        "529.9M", "549.2M", "498M",
        "552.1M", "533M", "483.9M"
    ],
    'Size_MB': [
        362.1, 372.8, 350.2, 391.0, 377.3, 324.0
    ],
    'Published': [
        "2011-01-05"
    ] * 6,
    'Instrument': [
        "Illumina Genome Analyzer II"
    ] * 6,
    'Strategy': ["WGS"] * 6,
    'Source': ["TRANSCRIPTOMIC"] * 6,
    'Layout': ["SINGLE"] * 6
}

df = pd.DataFrame(data)
df.to_csv("config/sample_metadata.csv", index=False)
