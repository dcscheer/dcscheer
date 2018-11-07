import re

# Gensim
import gensim
import gensim.corpora as corpora
from gensim.utils import simple_preprocess

# NLTK Stop words
from nltk.corpus import stopwords

stop_words = stopwords.words('english')
stop_words.extend(['from', 'subject', 're', 'edu', 'use'])

# spacy for lemmatization
import spacy

nlp = spacy.load('en', disable=['parser', 'ner'])

# import language detect
from langdetect import detect

import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)

from tqdm import tqdm


def remove_non_english(data, text_col):
    def find_lang(x):
        try:
            return detect(x)
        except:
            return 'none'

    tqdm.pandas()
    data['language'] = data[text_col].progress_apply(find_lang)

    return data.loc[data.language == 'en', :]


def pre_process_regex(data, text_col):
    # Convert to list
    data_re = data[text_col].values.tolist()

    # Remove new line characters
    print('remove new line characters')
    data_re = [re.sub('\s+', ' ', sent) for sent in tqdm(data_re)]

    # Remove distracting single quotes
    print('remove single quotes')
    data_re = [re.sub("\'", "", sent) for sent in tqdm(data_re)]

    return data_re


def sent_to_words(data):
    for sentence in tqdm(data):
        yield (gensim.utils.simple_preprocess(str(sentence), deacc=True))  # deacc=True removes punctuations


# Define functions for stopwords, bigrams, trigrams and lemmatization
def remove_stopwords(texts):
    return [[word for word in simple_preprocess(str(doc)) if word not in stop_words] for doc in tqdm(texts)]


def make_bigrams(texts):
    bigram = gensim.models.Phrases(texts, min_count=5, threshold=100)  # higher threshold fewer phrases.
    bigram_mod = gensim.models.phrases.Phraser(bigram)
    return [bigram_mod[doc] for doc in tqdm(texts)]


def make_trigrams(texts):
    bigram = gensim.models.Phrases(texts, min_count=5, threshold=100)  # higher threshold fewer phrases.
    bigram_mod = gensim.models.phrases.Phraser(bigram)
    trigram = gensim.models.Phrases(bigram[texts], threshold=100)
    trigram_mod = gensim.models.phrases.Phraser(trigram)
    return [trigram_mod[bigram_mod[doc]] for doc in tqdm(texts)]  


def lemmatization(texts, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV']):
    """https://spacy.io/api/annotation"""
    texts_out = []
    for sent in tqdm(texts):
        doc = nlp(" ".join(sent))
        texts_out.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
    return texts_out


def create_dictionary(data_lemmatized):
    return corpora.Dictionary(data_lemmatized)


def create_corpus(id2word, data_lemmatized):
    return [id2word.doc2bow(text) for text in tqdm(data_lemmatized)]


def lda_preprocess(data: object, text_col: object, trigrams=False) -> object:
    print('begin lda preprocessing')
    print('begin regex preprocess')
    data = pre_process_regex(data, text_col)
    print('end regex preprocess')

    print('begin sentence pre-process')
    data_words = list(sent_to_words(data))
    print('end sentence pre-process')

    print('begin remove stopwords')
    data_words_nostops = remove_stopwords(data_words)
    print('end remove stopwords')

    if trigrams == True:
        print('begin trigramming')
        data_words_ngrams = make_trigrams(data_words_nostops)
        print('end trigramming')

    else:
        print('begin bigramming')
        data_words_ngrams = make_bigrams(data_words_nostops)
        print('end bigramming')

    print('begin lemmatization')
    data_lemmatized = lemmatization(data_words_ngrams, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV'])
    print('end lemmatization')

    print('begin creating dictionary')
    id2word = create_dictionary(data_lemmatized)
    print('end creating dictionary')

    print('begin creating corpus')
    corpus = create_corpus(id2word, data_lemmatized)
    print('end creating corpus')
    print('end lda preprocessing')

    return id2word, corpus, data_lemmatized
