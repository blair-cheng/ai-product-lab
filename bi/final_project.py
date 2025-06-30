from langchain_openai import  ChatOpenAI, OpenAIEmbeddings
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
import pinecone,os,time
from langchain_pinecone import Pinecone
from langchain.chains import ConversationalRetrievalChain
from functools import lru_cache
from langchain.prompts import PromptTemplate



@lru_cache()
def get_qa_chain():
# 1. load pdf
    base_path = "/Users/xiaolincheng/Desktop/2025spring/dsci/final project"
    pdf_path  = os.path.join(base_path, "Generative_AI_App_Doc.pdf")

    loader = PyPDFLoader(pdf_path)
    pages = loader.load_and_split()


    # 2. document transform
    Openai_key_path = os.path.join(base_path, "my_OpenAI_key.txt")
    Pinecone_key_path = os.path.join(base_path, "my_pinecone_key.txt")

    with open(Openai_key_path,'r') as f:
        my_OpenAI_key = f.readline().strip()


    with open(Pinecone_key_path,'r') as f:
        my_Pinecone_key = f.readline().strip()


    # 2.1 splitter
    text_splitter = RecursiveCharacterTextSplitter(
        # Larger chunks so table numbers stay together
        chunk_size=1500,
        chunk_overlap=200,
        length_function=len,
        add_start_index=True,
    )
    split_doc = text_splitter.split_documents(pages)


    # 2.2 Openai Text Embedding Model
    EMBEDDING_MODEL = "text-embedding-ada-002"
    embeddings_model = OpenAIEmbeddings(model=EMBEDDING_MODEL,
                                        openai_api_key=my_OpenAI_key, 
                                        disallowed_special=())

    # 2.3 Pinecone
    PINECONE_API_KEY = my_Pinecone_key
    PINECONE_ENV = "gcp-starter"
    PINECONE_INDEX = "dsbi"   
    PINECONE_INDEX_HOST = 'https://dsbi-kvcrm02.svc.aped-4627-b74a.pinecone.io'
    INDEX_DIMENSIONS = 1536
    INDEX_METRIC = "cosine"
    os.environ['PINECONE_API_KEY'] = my_Pinecone_key

    pc = pinecone.Pinecone(api_key=my_Pinecone_key,
                        environment=PINECONE_ENV)



    index = pc.Index(name=PINECONE_INDEX, host=PINECONE_INDEX_HOST)

    # vectorstore
    docs_upload = Pinecone.from_existing_index(index_name=PINECONE_INDEX,
                                          embedding=embeddings_model)

    # Retriving information from the vectorstore
    retriever = docs_upload.as_retriever(
        search_type="mmr",
        search_kwargs={"k": 25, "fetch_k": 60}
    )
    language_model = "gpt-3.5-turbo-16k"
    model = ChatOpenAI(openai_api_key=my_OpenAI_key,
                    model_name=language_model, 
                    temperature=0.2)  



    qa_prompt = PromptTemplate(
        input_variables=["context", "question"],
        template=(
            "You are a life‑science analyst. Answer the question **only with information "
            "found in <context>.** If the answer is not in <context>, reply exactly: "
            "\"I don't know.\"\n\n"
            "—— RULES ——\n"
            "• Quote numbers exactly as they appear in <context>; do NOT create or round new numbers.\n"
            "• Do not add facts, speculations, or marketing language.\n"
            "• Answer in at least 3 complete sentences.\n\n"
            "<context>\n{context}\n\n"
            "Question: {question}\n\n"
            "Answer:"
        ),
    )
    qa = ConversationalRetrievalChain.from_llm(model, retriever=retriever, combine_docs_chain_kwargs={"prompt": qa_prompt},return_source_documents=True)
    return qa

if __name__ == "__main__":
    questions = [
        "What is the estimated development cost for PancreXcel?",
        "What information must be included in PancreXcel's proposed labeling?",
        "What is the role of the Target Product Profile (TPP) in the NDA process?",
        "What is the estimated development cost for PancreXcel?",
        "What is the overall success rate of PancreXcel in clinical development, and how does it change as it progresses from Phase II to Phase III and FDA approval?",
        "What achievement makes PancreXcel stand out in its Phase II development, and how does this achievement impact its prospects for Phase III and FDA approval?",
        "What are some specific funding risks mentioned for PancreXcel's development in the text?",
        "What factors contribute to the optimism regarding PancreXcel's potential for FDA approval despite a statistically lower anticipated success rate?",
        "What is the recommendation for the development of PancreXcel's pancreatic cancer therapy, and why was it made?"
    ]

    qa_chain = get_qa_chain()     

    for q in questions:
        ans = qa_chain.invoke({
            "question": q,
            "chat_history": []
        })["answer"]
        print(f"\nQ: {q}\nA: {ans}\n" + "-"*60)